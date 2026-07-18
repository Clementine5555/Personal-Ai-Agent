# Personal AI Agent — Implementation Plan

Membangun aplikasi chat AI agent pribadi yang berjalan di Android dan Windows dari satu codebase Flutter, dengan backend Node.js sebagai orchestrator, Supabase sebagai database & auth, Gemini sebagai LLM, dan Tavily untuk web search.

---

## Struktur Folder Project

```
d:\Personal AI\
├── backend/          ← Node.js + Express orchestrator
│   ├── src/
│   │   ├── adapters/     ← LLM abstraction (Gemini, Claude)
│   │   ├── tools/        ← Tavily web search tool
│   │   ├── routes/       ← Express routes
│   │   └── services/     ← Supabase, memory, dll
│   ├── .env.example
│   └── package.json
├── flutter_app/      ← Flutter app (Android + Windows)
│   ├── lib/
│   │   ├── screens/      ← Chat screen, login screen
│   │   ├── services/     ← API service, auth service
│   │   ├── widgets/      ← Chat bubble, input bar
│   │   └── models/       ← Message model
│   └── pubspec.yaml
├── supabase/         ← SQL migrations
│   └── migrations/
├── progress-log.txt
└── README.md
```

---

## Phase 1 — Supabase Setup

### Tabel yang dibuat:
- `conversations` — menyimpan sesi percakapan per user
- `messages` — menyimpan semua pesan (user & AI) per conversation
- `memory_embeddings` — untuk RAG (vector search, pakai pgvector)

### Auth:
- Enable Supabase Auth (email/password)
- Set whitelist: hanya email kamu yang boleh login
- Cara whitelist: buat trigger/hook di Supabase yang menolak signup email selain milikmu

---

## Phase 2 — Backend Node.js

### Stack:
- **Express.js** (lebih cocok dari FastAPI karena Flutter ekosistemnya JS-friendly, dan LLM SDK Gemini/Anthropic punya package npm resmi)
- **@google/generative-ai** — Gemini SDK
- **@anthropic-ai/sdk** — siap pakai kalau ganti ke Claude
- **@supabase/supabase-js** — koneksi ke Supabase
- **tavily** / custom fetch ke Tavily API

### Endpoint:
| Method | Path | Fungsi |
|--------|------|--------|
| POST | `/api/chat` | Kirim pesan, terima jawaban AI |
| GET | `/api/conversations` | Ambil daftar sesi chat |
| GET | `/api/conversations/:id/messages` | Ambil pesan dalam sesi |

### LLM Adapter Pattern:
```
src/adapters/
├── llm-adapter.js      ← interface / base class
├── gemini-adapter.js   ← implementasi Gemini
└── claude-adapter.js   ← implementasi Claude (standby)
```

Konfigurasi di `.env`:
```
LLM_PROVIDER=gemini   ← ganti ke 'claude' untuk switch provider
```

Backend akan import adapter berdasarkan nilai env ini — tidak perlu ubah kode lain.

### Tool Calling (Tavily):
LLM akan diberi "tool definition" bernama `web_search`. Kalau LLM memutuskan perlu search, backend intercept function call-nya, panggil Tavily API, lalu kirim hasilnya kembali ke LLM untuk dijadikan jawaban final.

---

## Phase 3 — Flutter App

### Packages Flutter:
- `http` — HTTP requests ke backend
- `supabase_flutter` — Supabase Auth
- `flutter_markdown` — render markdown dari jawaban AI
- `shared_preferences` — simpan token/session lokal

### Screens:
1. **LoginScreen** — form email + password, auth via Supabase
2. **ChatScreen** — daftar bubble chat, input bar, send button

### Flow Auth:
```
App start → cek session Supabase
  ├── ada session → langsung ke ChatScreen
  └── tidak ada → ke LoginScreen → login → ChatScreen
```

---

## Phase 4 — Security & Privacy

> [!IMPORTANT]
> Semua API key (Gemini, Tavily, Supabase) HANYA disimpan di file `.env` di server backend. Flutter app hanya tahu URL backend, tidak tahu API key apapun.

> [!WARNING]
> Backend di Render/Railway akan punya URL publik. Untuk keamanan pribadi, tambahkan **simple bearer token auth** di backend — Flutter app kirim token rahasia di setiap request, backend tolak request tanpa token yang benar. Token ini disimpan di env variable juga.

---

## Phase 5 — Build & Deploy

- **Backend**: deploy ke Render (free tier cukup untuk pemakaian pribadi)
- **Android**: `flutter build apk --release`
- **Windows**: `flutter build windows --release`

---

## Open Questions

> [!IMPORTANT]
> **Q1**: Untuk whitelist auth, apakah kamu mau pakai cara paling simpel (disable signup di Supabase dashboard + buat akun manual sekali), atau mau ada mekanisme otomatis yang menolak email lain?
> Rekomendasi saya: **disable signup, buat akun manual** — lebih simpel dan aman.

> [!IMPORTANT]
> **Q2**: Untuk keamanan backend, apakah kamu mau pakai **Supabase JWT** (token dari Supabase Auth dikirim ke backend dan backend verifikasi), atau **custom bearer token** sederhana (satu shared secret di env)?
> Rekomendasi saya: **Supabase JWT** — lebih proper, token otomatis expire, tidak ada shared secret yang perlu dijaga manual.

> [!NOTE]
> **Q3**: Apakah kamu sudah punya akun di: Supabase, Render/Railway, Google AI Studio (Gemini API key), Tavily? Kalau belum, saya bisa bantu step-by-step cara daftarnya.

> [!NOTE]
> **Q4**: Untuk memory/RAG (pgvector), ini adalah fitur lanjutan. Apakah kamu mau saya sertakan dari awal, atau skip dulu dan fokus ke chat fungsional terlebih dahulu?
> Rekomendasi saya: **skip RAG dulu**, tambah setelah chat dasar berjalan.

---

## Urutan Eksekusi

| # | Task | Status |
|---|------|--------|
| 1 | Buat SQL migrations Supabase (tabel + auth config) | ⏳ Pending |
| 2 | Setup project backend Node.js + struktur folder | ⏳ Pending |
| 3 | Buat LLM adapter layer (Gemini + Claude stub) | ⏳ Pending |
| 4 | Implementasi endpoint `/api/chat` + tool calling Tavily | ⏳ Pending |
| 5 | Implementasi simpan conversation & messages ke Supabase | ⏳ Pending |
| 6 | Setup project Flutter + struktur folder | ⏳ Pending |
| 7 | Buat LoginScreen + Supabase Auth di Flutter | ⏳ Pending |
| 8 | Buat ChatScreen + integrasi ke backend | ⏳ Pending |
| 9 | Deploy backend ke Render/Railway | ⏳ Pending |
| 10 | Build APK Android + test | ⏳ Pending |
| 11 | Build Windows executable + test | ⏳ Pending |
| 12 | Buat README + progress-log.txt final | ⏳ Pending |

---

## Verification Plan

### Backend:
- Test endpoint `/api/chat` dengan Postman/curl sebelum Flutter disentuh
- Verifikasi tool calling aktif (kirim query yang perlu info real-time)

### Flutter:
- Test login flow di emulator Android
- Test chat flow — kirim pesan, terima balasan AI
- Build APK dan install di device fisik

### Windows:
- Jalankan `flutter run -d windows` untuk test lokal
- Build release dan verifikasi executable berjalan tanpa Flutter SDK terinstall

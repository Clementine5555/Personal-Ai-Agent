# Personal AI Agent — README

Panduan setup project dari awal sampai bisa dijalankan.

---

## Prasyarat

| Tool | Kegunaannya | Link Install |
|------|-------------|-------------|
| Node.js v20+ | Menjalankan backend | https://nodejs.org |
| Flutter SDK 3.x | Build app Android & Windows | https://flutter.dev/docs/get-started/install |
| Android Studio | Emulator + Android SDK | https://developer.android.com/studio |
| Git | Version control | https://git-scm.com |

---

## Akun yang Dibutuhkan

| Layanan | Fungsi | Daftar di |
|---------|--------|-----------|
| Supabase | Database + Auth | https://supabase.com |
| Google AI Studio | Gemini API Key | https://aistudio.google.com |
| Tavily | Web Search API | https://app.tavily.com |
| Render / Railway | Deploy backend | https://render.com |

---

## Step 1: Setup Supabase

1. Buat project baru di https://supabase.com
2. Pergi ke **SQL Editor** di dashboard Supabase
3. Jalankan file `supabase/migrations/001_init.sql` (copy-paste isinya ke editor)
4. Pergi ke **Authentication → Settings**:
   - Matikan "Enable email confirmations" (biar tidak perlu klik link email)
   - Matikan "Enable new user signups" (PENTING! Supaya hanya kamu yang bisa punya akun)
5. Pergi ke **Authentication → Users → Add user** — buat akun dengan email dan password kamu
6. Catat nilai-nilai berikut dari **Project Settings → API**:
   - `Project URL` → ini adalah `SUPABASE_URL`
   - `anon public` key → ini adalah `SUPABASE_ANON_KEY` (untuk Flutter)
   - `service_role` key → ini adalah `SUPABASE_SERVICE_ROLE_KEY` (untuk backend)
   - `JWT Secret` (di tab JWT Settings) → untuk `SUPABASE_JWT_SECRET`

---

## Step 2: Setup Backend

```bash
# Masuk ke folder backend
cd backend

# Install semua dependency
npm install

# Salin template env dan isi nilainya
copy .env.example .env
# (Buka file .env dengan text editor dan isi semua nilai)

# Jalankan backend di mode development
npm run dev
```

Test backend berjalan dengan buka browser ke: `http://localhost:3000/health`
Harusnya tampil: `{"status":"ok","timestamp":"..."}`

---

## Step 3: Setup Flutter App

```bash
# Masuk ke folder flutter_app
cd flutter_app

# Install Flutter packages
flutter pub get

# Edit file lib/main.dart dan ganti:
# - _supabaseUrl → URL Supabase kamu
# - _supabaseAnonKey → Anon key Supabase kamu
# - URL backend di bagian backendUrl
```

---

## Step 4: Jalankan di Windows (Development)

```bash
cd flutter_app
flutter run -d windows
```

---

## Step 5: Jalankan di Android (Development)

1. Nyalakan **Developer Options** di HP Android kamu
2. Aktifkan **USB Debugging**
3. Colok HP ke komputer
4. Jalankan:

```bash
cd flutter_app
flutter devices        # Cek HP terdeteksi
flutter run -d <device-id>
```

---

## Build untuk Produksi

### Build APK Android

```bash
cd flutter_app
flutter build apk --release
# APK ada di: build/app/outputs/flutter-apk/app-release.apk
# Install ke HP: adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build Windows Executable

```bash
cd flutter_app
flutter build windows --release
# Hasil ada di: build/windows/x64/runner/Release/
# Jalankan: personal_ai_agent.exe
```

---

## Deploy Backend ke Render

1. Push kode ke GitHub (folder `backend/`)
2. Buat akun di https://render.com
3. New → Web Service → Connect GitHub repo
4. Konfigurasi:
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Environment**: Node
5. Tambahkan semua Environment Variables dari file `.env`
6. Deploy → salin URL Render (contoh: `https://personal-ai-xyz.onrender.com`)
7. Update URL backend di `flutter_app/lib/main.dart`
8. Rebuild APK dan Windows

---

## Ganti LLM Provider (Gemini → Claude)

Cukup edit satu baris di file `backend/.env`:

```env
LLM_PROVIDER=claude    # Ganti dari 'gemini' ke 'claude'
ANTHROPIC_API_KEY=sk-ant-...   # Pastikan ini sudah diisi
```

Restart backend — tidak perlu ubah kode apapun.

---

## Struktur Folder

```
Personal AI/
├── backend/              ← Node.js backend
│   ├── src/
│   │   ├── adapters/     ← LLM adapter (Gemini + Claude)
│   │   ├── middleware/   ← Auth middleware
│   │   ├── routes/       ← Express routes
│   │   ├── services/     ← Supabase service
│   │   └── tools/        ← Tavily web search
│   ├── .env.example      ← Template konfigurasi
│   └── package.json
├── flutter_app/          ← Flutter app
│   ├── lib/
│   │   ├── models/       ← Data models
│   │   ├── screens/      ← Login & Chat screens
│   │   ├── services/     ← API & Auth services
│   │   └── widgets/      ← ChatBubble widget
│   └── pubspec.yaml
├── supabase/
│   └── migrations/       ← SQL untuk setup database
└── progress-log.txt      ← Log progress per sesi
```

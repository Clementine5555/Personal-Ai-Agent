// =============================================================
// src/index.js — Entry point backend Express
// Ini file pertama yang dijalankan saat server start
// =============================================================

import 'dotenv/config';           // Muat semua variabel dari file .env
import express from 'express';
import cors from 'cors';
import chatRouter from './routes/chat.js';
import conversationsRouter from './routes/conversations.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware: izinkan request dari mana saja (Flutter app bisa kirim request)
// Untuk produksi pribadi ini oke, karena sudah ada JWT auth di setiap request
app.use(cors());

// Middleware: otomatis parse body JSON dari request
app.use(express.json());

// Daftarkan routes
app.use('/api/chat', chatRouter);
app.use('/api/conversations', conversationsRouter);

// Health check — untuk verifikasi server jalan (bisa di-test dari browser)
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Jalankan server
app.listen(PORT, () => {
    console.log(`✅ Backend berjalan di port ${PORT}`);
    console.log(`📦 LLM Provider: ${process.env.LLM_PROVIDER}`);
});

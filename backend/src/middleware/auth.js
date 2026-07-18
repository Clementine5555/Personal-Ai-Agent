// =============================================================
// src/middleware/auth.js — Middleware: verifikasi JWT setiap request
//
// 💡 Konsep Middleware di Express: fungsi yang "berdiri di tengah"
//    antara request masuk dan handler route.
//    Format: (req, res, next) => { ... next() }
//    Kalau next() dipanggil → lanjut ke handler berikutnya.
//    Kalau res.json() dipanggil → request berhenti di sini.
// =============================================================

import { verifyUserToken } from '../services/supabase.js';

export async function authMiddleware(req, res, next) {
    // Ambil token dari header: "Authorization: Bearer <token>"
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Token tidak ada atau format salah' });
    }

    const token = authHeader.split(' ')[1]; // Ambil bagian setelah "Bearer "

    // Verifikasi token ke Supabase
    const user = await verifyUserToken(token);

    if (!user) {
        return res.status(401).json({ error: 'Token tidak valid atau sudah expired' });
    }

    // Simpan data user ke req supaya bisa dipakai di handler route
    req.user = user;
    next(); // Lanjut ke route handler
}

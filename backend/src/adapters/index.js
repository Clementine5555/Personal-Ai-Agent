// =============================================================
// src/adapters/index.js — Factory: pilih adapter berdasarkan env
//
// 💡 Ini adalah "factory pattern": satu fungsi yang memutuskan
//    mau buat object jenis apa berdasarkan konfigurasi.
//    Kode lain cukup import getLLMAdapter() dan pakai, tidak perlu
//    tahu apakah hasilnya Gemini atau Claude.
// =============================================================

import { GeminiAdapter } from './gemini-adapter.js';
import { ClaudeAdapter } from './claude-adapter.js';

// Variabel ini dibuat sekali dan dipakai ulang (singleton pattern)
let adapterInstance = null;

export function getLLMAdapter() {
    if (adapterInstance) return adapterInstance; // Pakai yang sudah ada

    const provider = process.env.LLM_PROVIDER || 'gemini';

    if (provider === 'gemini') {
        adapterInstance = new GeminiAdapter();
    } else if (provider === 'claude') {
        adapterInstance = new ClaudeAdapter();
    } else {
        throw new Error(`LLM provider tidak dikenal: ${provider}. Pilih 'gemini' atau 'claude'`);
    }

    console.log(`🤖 Menggunakan LLM provider: ${provider}`);
    return adapterInstance;
}

// =============================================================
// src/adapters/llm-adapter.js — Interface/kontrak untuk semua LLM
//
// 💡 Konsep OOP: ini adalah "abstract class" / interface.
//    Semua adapter LLM (Gemini, Claude) HARUS punya method chat().
//    Tujuannya: kode lain cukup panggil adapter.chat(), tidak peduli
//    apakah di dalamnya pakai Gemini atau Claude.
// =============================================================

export class LLMAdapter {
    /**
     * Kirim pesan ke LLM dan terima balasan.
     * @param {Array} messages - Riwayat pesan [{role, content}, ...]
     * @param {Array} tools    - Daftar tool yang boleh dipanggil LLM
     * @returns {Object}       - { text, toolCall } — jawaban atau permintaan tool
     */
    // eslint-disable-next-line no-unused-vars
    async chat(messages, tools) {
        // Method ini HARUS di-override oleh class turunan
        throw new Error('Method chat() harus diimplementasikan oleh adapter');
    }
}

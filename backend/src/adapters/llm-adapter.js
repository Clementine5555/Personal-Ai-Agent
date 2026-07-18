export class LLMAdapter {
    /**
     * Kirim pesan ke LLM dan terima balasan.
     * @param {Array} messages - Riwayat pesan [{role, content}, ...]
     * @param {Array} tools    - Daftar tool yang boleh dipanggil LLM
     * @returns {Object}       - { text, toolCall } — jawaban atau permintaan tool
     */

    async chat(messages, tools) {

        throw new Error('Method chat() harus diimplementasikan oleh adapter');
    }
}

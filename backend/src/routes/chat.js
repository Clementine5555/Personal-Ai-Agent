// =============================================================
// src/routes/chat.js — Route POST /api/chat
//
// Ini adalah otak dari backend: menerima pesan user,
// memanggil LLM, menjalankan tool kalau diperlukan,
// menyimpan hasilnya ke database, lalu mengirim jawaban.
// =============================================================

import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { getLLMAdapter } from '../adapters/index.js';
import { webSearchToolDefinition, executeWebSearch } from '../tools/web-search.js';
import {
    createConversation,
    getMessages,
    saveMessage,
    updateConversationTitle,
} from '../services/supabase.js';

const router = Router();

// Daftar semua tools yang bisa dipakai LLM
const AVAILABLE_TOOLS = [webSearchToolDefinition];

// POST /api/chat
// Body: { message: string, conversationId?: string }
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { message, conversationId: existingConversationId } = req.body;
        const userId = req.user.id; // Diisi oleh authMiddleware

        if (!message || typeof message !== 'string') {
            return res.status(400).json({ error: 'Field "message" wajib diisi' });
        }

        // --- STEP 1: Siapkan atau buat conversation ---
        let conversationId = existingConversationId;

        if (!conversationId) {
            // Conversation baru — buat dulu di database
            const conv = await createConversation(userId);
            conversationId = conv.id;
            // Gunakan pesan pertama sebagai judul
            await updateConversationTitle(conversationId, message);
        }

        // --- STEP 2: Ambil riwayat pesan dari database ---
        const existingMessages = await getMessages(conversationId);

        // --- STEP 3: Simpan pesan user ke database ---
        await saveMessage(conversationId, 'user', message);

        // Susun riwayat percakapan untuk dikirim ke LLM
        // Format: [{role: 'user'|'assistant', content: '...'}]
        const chatHistory = [
            ...existingMessages.map((m) => ({ role: m.role, content: m.content })),
            { role: 'user', content: message },
        ];

        // --- STEP 4: Panggil LLM ---
        const llm = getLLMAdapter();
        let llmResult = await llm.chat(chatHistory, AVAILABLE_TOOLS);

        // --- STEP 5: Kalau LLM minta tool, jalankan tool-nya ---
        if (llmResult.toolCall) {
            const { name, args } = llmResult.toolCall;
            console.log(`🔧 LLM minta tool: ${name}`, args);

            let toolResult;
            if (name === 'web_search') {
                toolResult = await executeWebSearch(args.query);
            } else {
                toolResult = `Tool "${name}" tidak dikenal`;
            }

            // Kirim hasil tool kembali ke LLM untuk dijadikan jawaban final
            // 💡 Ini adalah "agentic loop": LLM → tool → LLM lagi
            llmResult = await llm.continueWithToolResult(
                chatHistory,
                name,
                toolResult,
                AVAILABLE_TOOLS
            );
        }

        // --- STEP 6: Simpan jawaban AI ke database ---
        const assistantReply = llmResult.text || 'Maaf, terjadi kesalahan.';
        await saveMessage(conversationId, 'assistant', assistantReply);

        // --- STEP 7: Kirim jawaban ke Flutter app ---
        res.json({
            reply: assistantReply,
            conversationId,
        });

    } catch (error) {
        console.error('❌ Error di /api/chat:', error);
        res.status(500).json({ error: 'Terjadi kesalahan di server' });
    }
});

export default router;

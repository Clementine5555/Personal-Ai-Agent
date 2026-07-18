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

const AVAILABLE_TOOLS = [webSearchToolDefinition];

router.post('/', authMiddleware, async (req, res) => {
    try {
        const { message, conversationId: existingConversationId } = req.body;
        const userId = req.user.id; 

        if (!message || typeof message !== 'string') {
            return res.status(400).json({ error: 'Field "message" wajib diisi' });
        }

        let conversationId = existingConversationId;

        if (!conversationId) {

            const conv = await createConversation(userId);
            conversationId = conv.id;

            await updateConversationTitle(conversationId, message);
        }

        const existingMessages = await getMessages(conversationId);

        await saveMessage(conversationId, 'user', message);

        const chatHistory = [
            ...existingMessages.map((m) => ({ role: m.role, content: m.content })),
            { role: 'user', content: message },
        ];

        const llm = getLLMAdapter();
        let llmResult = await llm.chat(chatHistory, AVAILABLE_TOOLS);

        if (llmResult.toolCall) {
            const { name, args } = llmResult.toolCall;
            console.log(`🔧 LLM minta tool: ${name}`, args);

            let toolResult;
            if (name === 'web_search') {
                toolResult = await executeWebSearch(args.query);
            } else {
                toolResult = `Tool "${name}" tidak dikenal`;
            }

            llmResult = await llm.continueWithToolResult(
                chatHistory,
                name,
                toolResult,
                AVAILABLE_TOOLS
            );
        }

        const assistantReply = llmResult.text || 'Maaf, terjadi kesalahan.';
        await saveMessage(conversationId, 'assistant', assistantReply);

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

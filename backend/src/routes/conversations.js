import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { getConversations, getMessages } from '../services/supabase.js';

const router = Router();

router.get('/', authMiddleware, async (req, res) => {
    try {
        const conversations = await getConversations(req.user.id);
        res.json({ conversations });
    } catch (error) {
        console.error('❌ Error ambil conversations:', error);
        res.status(500).json({ error: 'Gagal mengambil daftar percakapan' });
    }
});

router.get('/:id/messages', authMiddleware, async (req, res) => {
    try {
        const messages = await getMessages(req.params.id);
        res.json({ messages });
    } catch (error) {
        console.error('❌ Error ambil messages:', error);
        res.status(500).json({ error: 'Gagal mengambil pesan' });
    }
});

export default router;

import 'dotenv/config';           
import express from 'express';
import cors from 'cors';
import chatRouter from './routes/chat.js';
import conversationsRouter from './routes/conversations.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());

app.use(express.json());

app.use('/api/chat', chatRouter);
app.use('/api/conversations', conversationsRouter);

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
    console.log(`✅ Backend berjalan di port ${PORT}`);
    console.log(`📦 LLM Provider: ${process.env.LLM_PROVIDER}`);
});

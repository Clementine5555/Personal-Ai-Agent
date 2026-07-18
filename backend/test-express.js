import 'dotenv/config';
import express from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';

const app = express();
app.use(express.json());

app.post('/api/chat', async (req, res) => {
    try {
        console.log('Sending to Gemini...');
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        
        const chat = model.startChat();
        const result = await chat.sendMessage('hello');
        
        res.json({ reply: result.response.text() });
    } catch (error) {
        console.error('Caught error:', error.message);
        res.status(500).json({ error: 'Terjadi kesalahan' });
    }
});

const server = app.listen(3001, () => {
    console.log('Test server on 3001');
});

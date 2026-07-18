import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai';

async function testGemini() {
    try {
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        
        const tools = [{
            name: 'web_search',
            description: 'Search the web',
            parameters: {
                type: 'OBJECT',
                properties: { query: { type: 'STRING' } },
                required: ['query']
            }
        }];
        
        const chat = model.startChat({
            history: [],
            tools: [{ functionDeclarations: tools }]
        });
        
        console.log('Sending message...');
        const result = await chat.sendMessage('hello');
        console.log('Response:', result.response.text());
    } catch (e) {
        console.error('Caught Exception:', e.message);
    }
}

testGemini();

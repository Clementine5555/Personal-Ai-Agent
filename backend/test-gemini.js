import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai';

async function testGemini() {
    try {
        console.log('Testing Gemini API...');
        console.log('API Key (first 10 chars):', process.env.GEMINI_API_KEY ? process.env.GEMINI_API_KEY.substring(0, 10) : 'MISSING');
        
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        
        console.time('Gemini Request');
        const result = await model.generateContent('Say exactly: "hello test"');
        console.timeEnd('Gemini Request');
        
        console.log('Response:', result.response.text());
    } catch (e) {
        console.error('Error:', e.message);
    }
}

testGemini();

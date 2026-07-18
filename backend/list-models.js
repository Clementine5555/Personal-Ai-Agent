import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai';

async function listModels() {
    try {
        console.log('Using API Key:', process.env.GEMINI_API_KEY ? process.env.GEMINI_API_KEY.substring(0, 5) + '...' : 'MISSING');
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        
        console.log('Fetching list of available models...');
        // SDK unfortunately doesn't expose listModels directly on the main object in 0.21.0 in a documented way sometimes,
        // but wait, we can make a direct fetch request just to be safe.
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${process.env.GEMINI_API_KEY}`);
        
        if (!response.ok) {
            console.error('Fetch failed:', response.status, response.statusText);
            const text = await response.text();
            console.error(text);
            return;
        }
        
        const data = await response.json();
        const models = data.models.filter(m => m.supportedGenerationMethods.includes('generateContent')).map(m => m.name);
        console.log('\n✅ Available Models for generateContent:');
        models.forEach(m => console.log(' -', m));
        
    } catch (e) {
        console.error('Caught Exception:', e.message);
    }
}

listModels();

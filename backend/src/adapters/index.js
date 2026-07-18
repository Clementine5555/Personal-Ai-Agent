import { GeminiAdapter } from './gemini-adapter.js';
import { ClaudeAdapter } from './claude-adapter.js';

let adapterInstance = null;

export function getLLMAdapter() {
    if (adapterInstance) return adapterInstance; 

    const provider = process.env.LLM_PROVIDER || 'gemini';

    if (provider === 'gemini') {
        adapterInstance = new GeminiAdapter();
    } else if (provider === 'claude') {
        adapterInstance = new ClaudeAdapter();
    } else {
        throw new Error(`LLM provider tidak dikenal: ${provider}. Pilih 'gemini' atau 'claude'`);
    }

    console.log(`🤖 Menggunakan LLM provider: ${provider}`);
    return adapterInstance;
}

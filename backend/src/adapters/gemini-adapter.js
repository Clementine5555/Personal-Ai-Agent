import { GoogleGenerativeAI } from '@google/generative-ai';
import { LLMAdapter } from './llm-adapter.js';

export class GeminiAdapter extends LLMAdapter {
    constructor() {
        super(); 

        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

        this.model = genAI.getGenerativeModel({
            model: process.env.GEMINI_MODEL || 'gemini-1.5-flash',
            systemInstruction:
                'Kamu adalah asisten AI pribadi yang cerdas dan membantu. ' +
                'Jawab dalam bahasa yang sama dengan pertanyaan user. ' +
                'Gunakan tool web_search kalau butuh informasi terkini.',
        });
    }

    async chat(messages, tools = []) {

        const history = messages.slice(0, -1).map((m) => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{ text: m.content }],
        }));

        const lastMessage = messages[messages.length - 1].content;

        const functionDeclarations = tools.map((t) => ({
            name: t.name,
            description: t.description,
            parameters: t.parameters,
        }));

        const chat = this.model.startChat({
            history,
            tools: functionDeclarations.length > 0
                ? [{ functionDeclarations }]
                : [],
        });

        const result = await chat.sendMessage(lastMessage);
        const response = result.response;

        const functionCall = response.candidates?.[0]?.content?.parts?.find(
            (p) => p.functionCall
        );

        if (functionCall) {

            return {
                text: null,
                toolCall: {
                    name: functionCall.functionCall.name,
                    args: functionCall.functionCall.args,
                },
            };
        }

        return { text: response.text(), toolCall: null };
    }

    async continueWithToolResult(messages, toolName, toolResult, tools = []) {
        const history = messages.map((m) => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{ text: m.content }],
        }));

        const functionDeclarations = tools.map((t) => ({
            name: t.name,
            description: t.description,
            parameters: t.parameters,
        }));

        const chat = this.model.startChat({
            history: history.slice(0, -1),
            tools: functionDeclarations.length > 0
                ? [{ functionDeclarations }]
                : [],
        });

        const result = await chat.sendMessage([
            { text: history[history.length - 1].parts[0].text },
            {
                functionResponse: {
                    name: toolName,
                    response: { result: toolResult },
                },
            },
        ]);

        return { text: result.response.text(), toolCall: null };
    }
}

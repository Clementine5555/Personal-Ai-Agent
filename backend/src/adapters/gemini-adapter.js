// =============================================================
// src/adapters/gemini-adapter.js — Implementasi LLM untuk Gemini
//
// 💡 Konsep OOP: class ini "extends" (mewarisi) LLMAdapter.
//    Artinya GeminiAdapter punya semua yang ada di LLMAdapter,
//    tapi method chat() di-override dengan implementasi Gemini.
// =============================================================

import { GoogleGenerativeAI } from '@google/generative-ai';
import { LLMAdapter } from './llm-adapter.js';

export class GeminiAdapter extends LLMAdapter {
    constructor() {
        super(); // Panggil constructor parent class dulu

        // Inisialisasi Gemini client dengan API key dari .env
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

        // Pilih model dari env variable (defaultnya gemini-1.5-flash)
        this.model = genAI.getGenerativeModel({
            model: process.env.GEMINI_MODEL || 'gemini-1.5-flash',
            systemInstruction:
                'Kamu adalah asisten AI pribadi yang cerdas dan membantu. ' +
                'Jawab dalam bahasa yang sama dengan pertanyaan user. ' +
                'Gunakan tool web_search kalau butuh informasi terkini.',
        });
    }

    // Override method chat() dari parent class
    async chat(messages, tools = []) {
        // Konversi format messages ke format yang Gemini mau
        // Gemini pakai 'model' bukan 'assistant'
        const history = messages.slice(0, -1).map((m) => ({
            role: m.role === 'assistant' ? 'model' : 'user',
            parts: [{ text: m.content }],
        }));

        // Pesan terakhir adalah pesan user yang baru dikirim
        const lastMessage = messages[messages.length - 1].content;

        // Konversi format tools ke format Gemini function declarations
        const functionDeclarations = tools.map((t) => ({
            name: t.name,
            description: t.description,
            parameters: t.parameters,
        }));

        // Buka sesi chat dengan riwayat percakapan
        const chat = this.model.startChat({
            history,
            tools: functionDeclarations.length > 0
                ? [{ functionDeclarations }]
                : [],
        });

        // 💡 Async/await: kirim pesan ke Gemini, tunggu hasilnya
        const result = await chat.sendMessage(lastMessage);
        const response = result.response;

        // Cek apakah Gemini minta panggil sebuah tool (function call)
        const functionCall = response.candidates?.[0]?.content?.parts?.find(
            (p) => p.functionCall
        );

        if (functionCall) {
            // LLM minta tool dipanggil — return info tool call-nya
            return {
                text: null,
                toolCall: {
                    name: functionCall.functionCall.name,
                    args: functionCall.functionCall.args,
                },
            };
        }

        // LLM langsung jawab teks
        return { text: response.text(), toolCall: null };
    }

    // Method khusus untuk mengirim hasil tool kembali ke Gemini
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

        // Kirim pesan + hasil tool sekaligus
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

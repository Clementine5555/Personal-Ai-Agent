// =============================================================
// src/tools/web-search.js — Tool: web search via Tavily API
//
// Tool ini dipanggil oleh backend ketika LLM meminta web search.
// LLM tidak langsung ke Tavily — backend yang jadi perantara.
// =============================================================

// Definisi tool yang dikirim ke LLM supaya LLM tahu cara pakainya
export const webSearchToolDefinition = {
    name: 'web_search',
    description:
        'Cari informasi terkini dari internet. ' +
        'Gunakan tool ini ketika pertanyaan butuh data real-time, ' +
        'berita terbaru, harga, cuaca, atau informasi yang mungkin berubah.',
    parameters: {
        type: 'object',
        properties: {
            query: {
                type: 'string',
                description: 'Query pencarian dalam bahasa yang paling efektif',
            },
        },
        required: ['query'],
    },
};

/**
 * Panggil Tavily API untuk melakukan web search.
 * @param {string} query - Kata kunci pencarian
 * @returns {string} - Ringkasan hasil pencarian
 */
export async function executeWebSearch(query) {
    console.log(`🔍 Web search: "${query}"`);

    // 💡 Async/await dengan fetch: kirim HTTP request ke Tavily,
    //    tunggu hasilnya, lalu parsing JSON-nya
    const response = await fetch('https://api.tavily.com/search', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${process.env.TAVILY_API_KEY}`,
        },
        body: JSON.stringify({
            query,
            search_depth: 'basic',  // 'basic' lebih cepat, 'advanced' lebih detail
            max_results: 5,
            include_answer: true,   // Minta Tavily buat ringkasan jawaban
        }),
    });

    if (!response.ok) {
        throw new Error(`Tavily API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();

    // Format hasil: kalau ada ringkasan Tavily, pakai itu.
    // Kalau tidak, gabungkan snippet dari hasil pertama.
    if (data.answer) {
        return `Ringkasan: ${data.answer}\n\nSumber: ${
            data.results?.map((r) => r.url).join(', ') || ''
        }`;
    }

    // Fallback: ambil title + content dari hasil teratas
    const topResults = (data.results || []).slice(0, 3);
    return topResults
        .map((r) => `[${r.title}]\n${r.content}`)
        .join('\n\n---\n\n');
}

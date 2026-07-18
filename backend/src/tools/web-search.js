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

    const response = await fetch('https://api.tavily.com/search', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${process.env.TAVILY_API_KEY}`,
        },
        body: JSON.stringify({
            query,
            search_depth: 'basic',  
            max_results: 5,
            include_answer: true,   
        }),
    });

    if (!response.ok) {
        throw new Error(`Tavily API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();

    if (data.answer) {
        return `Ringkasan: ${data.answer}\n\nSumber: ${
            data.results?.map((r) => r.url).join(', ') || ''
        }`;
    }

    const topResults = (data.results || []).slice(0, 3);
    return topResults
        .map((r) => `[${r.title}]\n${r.content}`)
        .join('\n\n---\n\n');
}

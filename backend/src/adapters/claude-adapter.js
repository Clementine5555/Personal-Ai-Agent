import Anthropic from '@anthropic-ai/sdk';
import { LLMAdapter } from './llm-adapter.js';

export class ClaudeAdapter extends LLMAdapter {
    constructor() {
        super();
        this.client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
        this.model = process.env.CLAUDE_MODEL || 'claude-3-5-sonnet-20241022';
    }

    async chat(messages, tools = []) {

        const anthropicTools = tools.map((t) => ({
            name: t.name,
            description: t.description,
            input_schema: t.parameters,
        }));

        const response = await this.client.messages.create({
            model: this.model,
            max_tokens: 4096,
            system:
                'Kamu adalah asisten AI pribadi yang cerdas dan membantu. ' +
                'Jawab dalam bahasa yang sama dengan pertanyaan user. ' +
                'Gunakan tool web_search kalau butuh informasi terkini.',
            messages: messages.map((m) => ({
                role: m.role === 'assistant' ? 'assistant' : 'user',
                content: m.content,
            })),
            tools: anthropicTools.length > 0 ? anthropicTools : undefined,
        });

        const toolUse = response.content.find((c) => c.type === 'tool_use');
        if (toolUse) {
            return {
                text: null,
                toolCall: { name: toolUse.name, args: toolUse.input },
            };
        }

        const textBlock = response.content.find((c) => c.type === 'text');
        return { text: textBlock?.text || '', toolCall: null };
    }

    async continueWithToolResult(messages, toolName, toolResult, tools = []) {
        const anthropicTools = tools.map((t) => ({
            name: t.name,
            description: t.description,
            input_schema: t.parameters,
        }));

        const messagesWithTool = [
            ...messages.slice(0, -1).map((m) => ({
                role: m.role === 'assistant' ? 'assistant' : 'user',
                content: m.content,
            })),
            {
                role: 'user',
                content: [
                    {
                        type: 'tool_result',
                        tool_use_id: 'tool_id',
                        content: JSON.stringify(toolResult),
                    },
                ],
            },
        ];

        const response = await this.client.messages.create({
            model: this.model,
            max_tokens: 4096,
            system:
                'Kamu adalah asisten AI pribadi yang cerdas dan membantu.',
            messages: messagesWithTool,
            tools: anthropicTools.length > 0 ? anthropicTools : undefined,
        });

        const textBlock = response.content.find((c) => c.type === 'text');
        return { text: textBlock?.text || '', toolCall: null };
    }
}

-- =============================================================
-- Migration 001: Initial schema untuk Personal AI Agent
-- Jalankan file ini di Supabase Dashboard → SQL Editor
-- =============================================================

-- Tabel conversations: menyimpan sesi chat per user
-- Setiap kali buka "obrolan baru", 1 baris baru dibuat di sini
CREATE TABLE IF NOT EXISTS public.conversations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title       TEXT NOT NULL DEFAULT 'New Chat',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tabel messages: menyimpan setiap pesan dalam sebuah conversation
-- role: 'user' atau 'assistant'
CREATE TABLE IF NOT EXISTS public.messages (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id  UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    role             TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content          TEXT NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index supaya query pesan per conversation lebih cepat
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id
    ON public.messages(conversation_id);

-- Index supaya query conversation per user lebih cepat
CREATE INDEX IF NOT EXISTS idx_conversations_user_id
    ON public.conversations(user_id);

-- =============================================================
-- Row Level Security (RLS): user hanya bisa baca data miliknya
-- =============================================================

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policy conversations: user hanya bisa SELECT/INSERT/UPDATE/DELETE
-- row yang user_id-nya sama dengan user yang sedang login
CREATE POLICY "Users can manage own conversations"
    ON public.conversations
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy messages: user bisa akses messages dari conversation miliknya
CREATE POLICY "Users can manage messages in own conversations"
    ON public.messages
    FOR ALL
    USING (
        conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        conversation_id IN (
            SELECT id FROM public.conversations WHERE user_id = auth.uid()
        )
    );

-- =============================================================
-- Function: auto-update kolom updated_at setiap ada perubahan
-- =============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

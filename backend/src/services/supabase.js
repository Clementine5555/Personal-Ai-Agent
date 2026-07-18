import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
);

/**
 * Verifikasi JWT token yang dikirim Flutter app.
 * Token ini diambil dari Supabase Auth setelah user login di Flutter.
 * @param {string} token - Bearer token dari header Authorization
 * @returns {Object|null} - Data user kalau valid, null kalau tidak
 */
export async function verifyUserToken(token) {
    const { data, error } = await supabase.auth.getUser(token);
    if (error || !data.user) return null;
    return data.user;
}

/**
 * Buat conversation baru untuk user.
 * @param {string} userId - UUID user dari Supabase Auth
 * @param {string} title  - Judul percakapan (opsional)
 */
export async function createConversation(userId, title = 'New Chat') {
    const { data, error } = await supabase
        .from('conversations')
        .insert({ user_id: userId, title })
        .select()
        .single();  

    if (error) throw new Error(`Gagal buat conversation: ${error.message}`);
    return data;
}

/**
 * Ambil semua conversation milik user, diurutkan terbaru dulu.
 */
export async function getConversations(userId) {
    const { data, error } = await supabase
        .from('conversations')
        .select('*')
        .eq('user_id', userId)          
        .order('updated_at', { ascending: false }); 

    if (error) throw new Error(`Gagal ambil conversations: ${error.message}`);
    return data;
}

/**
 * Ambil semua pesan dalam sebuah conversation.
 */
export async function getMessages(conversationId) {
    const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', { ascending: true }); 

    if (error) throw new Error(`Gagal ambil messages: ${error.message}`);
    return data;
}

/**
 * Simpan satu pesan ke database.
 * @param {string} conversationId - ID conversation
 * @param {string} role    - 'user' atau 'assistant'
 * @param {string} content - Isi pesan
 */
export async function saveMessage(conversationId, role, content) {
    const { data, error } = await supabase
        .from('messages')
        .insert({ conversation_id: conversationId, role, content })
        .select()
        .single();

    if (error) throw new Error(`Gagal simpan message: ${error.message}`);
    return data;
}

/**
 * Update judul conversation (biasanya diambil dari pesan pertama user).
 */
export async function updateConversationTitle(conversationId, title) {
    const { error } = await supabase
        .from('conversations')
        .update({ title: title.substring(0, 100) }) 
        .eq('id', conversationId);

    if (error) console.warn('Gagal update title:', error.message);
}

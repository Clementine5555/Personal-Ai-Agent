import { verifyUserToken } from '../services/supabase.js';

export async function authMiddleware(req, res, next) {

    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Token tidak ada atau format salah' });
    }

    const token = authHeader.split(' ')[1]; 

    const user = await verifyUserToken(token);

    if (!user) {
        return res.status(401).json({ error: 'Token tidak valid atau sudah expired' });
    }

    req.user = user;
    next(); 
}

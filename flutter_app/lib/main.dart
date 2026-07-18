// =============================================================
// lib/main.dart — Entry point Flutter app
//
// 💡 Konsep: void main() adalah titik awal program, seperti
//    main() di Java/C. runApp() menjalankan widget pertama.
//    Semua UI di Flutter adalah "widget" — mirip komponen di React.
// =============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

// ⚠️ Nilai ini SUDAH diisi — jangan share ke orang lain!
// URL Supabase project kamu
const String _supabaseUrl = 'https://phkybecpakzgyexwoeix.supabase.co';

// Anon/public key Supabase (aman di client, dilindungi RLS + Auth)
const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoa3liZWNwYWt6Z3lleHdvZWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzNDU0NzUsImV4cCI6MjA5OTkyMTQ3NX0.Bq9A4SIpZYgqcocI2zfr4PxM4mhsAg1lXmQwwIdmNcw';

// 💡 async/await: main() bisa async karena Supabase.initialize()
//    butuh waktu (operasi network/IO)
void main() async {
  // Pastikan Flutter binding sudah siap sebelum panggil hal async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase — ini harus dilakukan sebelum runApp()
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Baca URL backend dari SharedPreferences (kalau sudah pernah disimpan)
  final prefs = await SharedPreferences.getInstance();
  final backendUrl = prefs.getString('backend_url') ??
      'http://localhost:3000'; // Untuk testing lokal di Windows

  // Inisialisasi API service dengan URL backend
  ApiService.instance.setBaseUrl(backendUrl);

  runApp(const PersonalAIApp());
}

// 💡 StatelessWidget: widget yang tidak punya "state" yang berubah.
//    Cocok untuk widget yang isinya tetap (seperti konfigurasi app).
class PersonalAIApp extends StatelessWidget {
  const PersonalAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal AI',
      debugShowCheckedModeBanner: false,

      // Tema gelap dengan aksen biru-ungu
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // Tentukan halaman awal berdasarkan status login
      home: const AppRouter(),
    );
  }
}

// Router sederhana: cek apakah user sudah login
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase.instance.client.auth.currentSession → null kalau belum login
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const ChatScreen(); // Sudah login → langsung ke chat
    } else {
      return const LoginScreen(); // Belum login → ke halaman login
    }
  }
}

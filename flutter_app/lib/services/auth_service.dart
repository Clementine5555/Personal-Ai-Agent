// =============================================================
// lib/services/auth_service.dart — Semua urusan login/logout
//
// 💡 Singleton pattern: class ini punya satu instance global
//    yang bisa diakses dari mana saja via AuthService.instance
//    Tujuan: tidak perlu bikin objek baru berulang kali
// =============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Singleton: satu instance yang dipakai seluruh app
  static final AuthService instance = AuthService._internal();
  // Private constructor — mencegah pembuatan instance dari luar
  AuthService._internal();

  // Shortcut ke Supabase auth client
  final _auth = Supabase.instance.client.auth;

  /// Login dengan email dan password
  /// Melempar exception kalau login gagal
  Future<void> signIn(String email, String password) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception('Login gagal: tidak ada session yang dibuat');
    }
  }

  /// Logout dari app
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Ambil access token JWT untuk dikirim ke backend
  /// Token ini di-refresh otomatis oleh Supabase SDK
  String? get accessToken => _auth.currentSession?.accessToken;

  /// Cek apakah user sedang login
  bool get isLoggedIn => _auth.currentSession != null;

  /// Ambil email user yang sedang login
  String? get userEmail => _auth.currentUser?.email;

  /// Stream perubahan auth state (login/logout event)
  /// 💡 Stream: seperti "aliran data" yang bisa didengarkan.
  ///    Setiap kali status berubah, listener akan dipanggil.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}

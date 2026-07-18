import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  final _auth = Supabase.instance.client.auth;

  Future<void> signIn(String email, String password) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception('Login gagal: tidak ada session yang dibuat');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get accessToken => _auth.currentSession?.accessToken;

  bool get isLoggedIn => _auth.currentSession != null;

  String? get userEmail => _auth.currentUser?.email;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}

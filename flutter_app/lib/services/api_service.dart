// =============================================================
// lib/services/api_service.dart — HTTP client ke backend
//
// Semua komunikasi dengan backend Node.js lewat class ini.
// JWT token otomatis disertakan di setiap request.
// =============================================================

import 'dart:convert';   // Untuk jsonEncode dan jsonDecode
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ApiService {
  // Singleton pattern (sama seperti AuthService)
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String _baseUrl = '';

  /// Set URL backend (dipanggil dari main.dart)
  void setBaseUrl(String url) {
    // Hapus trailing slash kalau ada
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Buat header standar untuk setiap request
  /// Menyertakan JWT token supaya backend bisa verifikasi identitas
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService.instance.accessToken ?? ''}',
  };

  // ----------------------------------------------------------
  // Chat
  // ----------------------------------------------------------

  /// Kirim pesan ke backend dan terima balasan AI
  /// Returns: Map berisi 'reply' dan 'conversationId'
  Future<Map<String, String>> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
      }),
    );

    _checkStatus(response); // Lempar exception kalau ada error

    // jsonDecode: ubah string JSON menjadi Map Dart
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'reply': data['reply'] as String,
      'conversationId': data['conversationId'] as String,
    };
  }

  // ----------------------------------------------------------
  // Conversations
  // ----------------------------------------------------------

  /// Ambil semua conversation milik user
  Future<List<Conversation>> getConversations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/conversations'),
      headers: _headers,
    );

    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Cast ke List lalu map setiap item ke object Conversation
    final list = data['conversations'] as List<dynamic>;
    return list.map((j) => Conversation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Ambil semua pesan dalam sebuah conversation
  Future<List<Message>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/conversations/$conversationId/messages'),
      headers: _headers,
    );

    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final list = data['messages'] as List<dynamic>;
    return list.map((j) => Message.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ----------------------------------------------------------
  // Helper
  // ----------------------------------------------------------

  /// Cek HTTP status code — lempar exception kalau bukan 2xx
  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Coba parse pesan error dari body
      String errorMsg = 'Error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        errorMsg = body['error'] as String? ?? errorMsg;
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }
}

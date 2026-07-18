import 'dart:convert';   
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ApiService {

  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String _baseUrl = '';

  void setBaseUrl(String url) {

    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService.instance.accessToken ?? ''}',
  };

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

    _checkStatus(response); 

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'reply': data['reply'] as String,
      'conversationId': data['conversationId'] as String,
    };
  }

  Future<List<Conversation>> getConversations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/conversations'),
      headers: _headers,
    );

    _checkStatus(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final list = data['conversations'] as List<dynamic>;
    return list.map((j) => Conversation.fromJson(j as Map<String, dynamic>)).toList();
  }

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

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {

      String errorMsg = 'Error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        errorMsg = body['error'] as String? ?? errorMsg;
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }
}

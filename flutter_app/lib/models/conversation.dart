// =============================================================
// lib/models/conversation.dart — Model untuk sesi percakapan
// =============================================================

class Conversation {
  final String id;
  final String title;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Chat',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

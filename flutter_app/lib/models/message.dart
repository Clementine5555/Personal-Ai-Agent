enum MessageRole { user, assistant }

class Message {

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Message.temporary({
    required MessageRole role,
    required String content,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  bool get isUser => role == MessageRole.user;
}

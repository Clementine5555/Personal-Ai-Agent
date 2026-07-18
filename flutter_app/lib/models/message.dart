// =============================================================
// lib/models/message.dart — Model data untuk sebuah pesan chat
//
// 💡 Konsep OOP — Class sebagai "blueprint":
//    Class Message adalah template/cetakan untuk membuat objek pesan.
//    Setiap pesan punya: id, role (siapa yang ngomong), dan content (isinya).
// =============================================================

// Enum: tipe data yang nilainya terbatas pada pilihan tertentu
// Di sini role hanya bisa 'user' atau 'assistant'
enum MessageRole { user, assistant }

class Message {
  // 'final' = nilai tidak bisa diubah setelah dibuat (immutable)
  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  // Constructor: cara membuat objek Message baru
  // Sintaks {required ...} = named parameter, wajib diisi
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  // Factory constructor: buat Message dari Map (hasil JSON dari API/database)
  // 💡 'factory' = constructor yang bisa punya logika lebih kompleks
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Buat Message sementara (untuk ditampilkan sebelum disimpan ke DB)
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

  // Getter (properti computed): apakah pesan ini dari user?
  bool get isUser => role == MessageRole.user;
}

// =============================================================
// lib/widgets/chat_bubble.dart — Widget bubble chat
//
// 💡 StatelessWidget: widget yang isinya ditentukan hanya dari
//    parameter yang diberikan saat dibuat — tidak ada state internal.
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        // Pesan user di kanan, AI di kiri
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar AI (hanya tampil untuk pesan AI)
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble isi pesan
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                // Warna berbeda untuk user vs AI
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4), // Sudut lancip di sisi avatar
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
              ),
              // Render markdown untuk pesan AI (bold, list, code, dll)
              // Pesan user ditampilkan sebagai teks biasa
              child: isUser
                  ? Text(
                      message.content,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                        ),
                        code: TextStyle(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          ),

          // Spacer untuk pesan AI (supaya tidak mentok kanan)
          if (!isUser) const SizedBox(width: 40),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget loading indicator — muncul saat menunggu jawaban AI
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

// 💡 StatefulWidget + State: widget yang bisa berubah (animasi, data dinamis).
//    State tersimpan di class _TypingIndicatorState yang terpisah.
class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animasi fade in-out berulang untuk indikator "AI sedang mengetik"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // repeat(reverse: true) = maju-mundur terus

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Penting! Hentikan animasi saat widget dihapus
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            // FadeTransition: animasikan opacity berdasarkan _animation
            child: FadeTransition(
              opacity: _animation,
              child: Row(
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: theme.colorScheme.primary,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

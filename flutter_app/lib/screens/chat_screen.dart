import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/chat_bubble.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();

  final _scrollController = ScrollController();

  List<Message> _messages = [];           
  List<Conversation> _conversations = []; 
  String? _activeConversationId;          
  bool _isLoading = false;                
  bool _isLoadingHistory = false;         
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations(); 
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final convs = await ApiService.instance.getConversations();
      setState(() => _conversations = convs);
    } catch (e) {

      debugPrint('Gagal load conversations: $e');
    }
  }

  Future<void> _openConversation(Conversation conv) async {
    setState(() {
      _activeConversationId = conv.id;
      _messages = [];
      _isLoadingHistory = true;
    });

    try {
      final msgs = await ApiService.instance.getMessages(conv.id);
      setState(() => _messages = msgs);
      _scrollToBottom();
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat riwayat pesan');
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  void _newConversation() {
    setState(() {
      _messages = [];
      _activeConversationId = null;
      _errorMessage = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMessage = Message.temporary(
      role: MessageRole.user,
      content: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _errorMessage = null;
    });

    _inputController.clear();
    _scrollToBottom();

    try {

      final result = await ApiService.instance.sendMessage(
        message: text,
        conversationId: _activeConversationId,
      );

      if (_activeConversationId == null) {
        setState(() => _activeConversationId = result['conversationId']);
        _loadConversations(); 
      }

      final aiMessage = Message.temporary(
        role: MessageRole.assistant,
        content: result['reply'] ?? 'Tidak ada balasan',
      );

      setState(() => _messages.add(aiMessage));
      _scrollToBottom();

    } catch (e) {
      setState(() => _errorMessage = 'Gagal kirim pesan: ${e.toString()}');

      setState(() => _messages.removeLast());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(

      drawer: isWideScreen ? null : _buildDrawer(theme),
      body: Row(
        children: [

          if (isWideScreen) _buildSidebar(theme),

          Expanded(child: _buildChatArea(theme, isWideScreen)),
        ],
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 260,
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        children: [

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Personal AI',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _newConversation,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Chat Baru'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _conversations.length,
              itemBuilder: (_, i) {
                final conv = _conversations[i];
                final isActive = conv.id == _activeConversationId;
                return ListTile(
                  dense: true,
                  selected: isActive,
                  selectedTileColor: theme.colorScheme.primaryContainer,
                  leading: Icon(Icons.chat_bubble_outline,
                      size: 18,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant),
                  title: Text(
                    conv.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _openConversation(conv),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                );
              },
            ),
          ),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.logout, size: 18),
              title: Text(AuthService.instance.userEmail ?? 'User',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
              onTap: _handleLogout,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(child: _buildSidebar(theme));
  }

  Widget _buildChatArea(ThemeData theme, bool isWideScreen) {
    return Column(
      children: [

        AppBar(
          automaticallyImplyLeading: !isWideScreen,
          title: Text(
            _activeConversationId == null ? 'Chat Baru' : 'Personal AI',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          backgroundColor: theme.colorScheme.surface,
          actions: [
            if (!isWideScreen)
              IconButton(
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: 'Chat Baru',
                onPressed: _newConversation,
              ),
            if (!isWideScreen)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: _handleLogout,
              ),
          ],
        ),

        if (_errorMessage != null)
          MaterialBanner(
            content: Text(_errorMessage!),
            backgroundColor: theme.colorScheme.errorContainer,
            actions: [
              TextButton(
                onPressed: () => setState(() => _errorMessage = null),
                child: const Text('Tutup'),
              ),
            ],
          ),

        Expanded(
          child: _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? _buildEmptyState(theme) 
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (_, i) {

                        if (i == _messages.length) {
                          return const TypingIndicator();
                        }
                        return ChatBubble(message: _messages[i]);
                      },
                    ),
        ),

        _buildInputBar(theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome,
              size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Halo! Ada yang bisa saya bantu?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              )),
          const SizedBox(height: 8),
          Text('Ketik pesan untuk mulai',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              )),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
        ),
        child: Row(
          children: [

            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 5, 
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),

            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _isLoading ? null : _sendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Icon(Icons.send_rounded,
                          color: theme.colorScheme.onPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

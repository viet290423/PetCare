import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../provider/MessagingProvider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String? otherUserName;
  final String? otherUserAvatar;
  const ChatScreen({super.key, required this.conversationId, this.otherUserName, this.otherUserAvatar});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MessagingProvider>();
      provider.openConversation(widget.conversationId);
      provider.subscribeToConversation(widget.conversationId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = context.read<MessagingProvider>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      provider.loadMoreMessages(widget.conversationId);
    }
  }

  @override
  void dispose() {
    context.read<MessagingProvider>().unsubscribeFromConversation();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: (widget.otherUserAvatar != null && (widget.otherUserAvatar?.isNotEmpty ?? false))
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: (widget.otherUserAvatar == null || widget.otherUserAvatar!.isEmpty)
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.otherUserName ?? 'Đoạn chat',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingMessages && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.messagesError != null && provider.messages.isEmpty) {
                  return Center(child: Text(provider.messagesError!));
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: provider.messages.length + (provider.isLoadingMessages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final msg = provider.messages[index];
                    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                    final isMine = currentUserId != null && msg.senderId == currentUserId;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMine ? Colors.green.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildComposer(context),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () async {
              final text = _controller.text;
              _controller.clear();
              await context.read<MessagingProvider>().sendMessage(widget.conversationId, text);
            },
          ),
        ],
      ),
    );
  }
}



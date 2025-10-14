import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/MessagingProvider.dart';
import 'ChatScreen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tin nhắn',
          style: const TextStyle(fontWeight: FontWeight.bold),

        ),
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingConversations) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.conversationsError != null) {
            return Center(
              child: Text(provider.conversationsError!),
            );
          }
          if (provider.conversations.isEmpty) {
            return const Center(child: Text('Chưa có cuộc trò chuyện'));
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadConversations(),
            child: ListView.separated(
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = provider.conversations[index];
                final subtitle = conv.lastMessage ?? '';
                final time = conv.lastMessageTime ?? conv.createdAt;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (conv.otherUserAvatar != null && (conv.otherUserAvatar?.isNotEmpty ?? false))
                        ? NetworkImage(conv.otherUserAvatar!)
                        : null,
                    child: (conv.otherUserAvatar == null || conv.otherUserAvatar!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(conv.otherUserName ?? 'Người dùng'),
                  subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(_formatTime(time)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: conv.id,
                          otherUserName: conv.otherUserName,
                          otherUserAvatar: conv.otherUserAvatar,
                        ),
                      ),
                    ).then((_) {
                      // refresh conversations when returning from chat
                      context.read<MessagingProvider>().loadConversations();
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}



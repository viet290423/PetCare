import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entity/Conversation.dart';
import '../../domain/entity/Message.dart';
import '../../domain/usecase/messaging/GetConversationsUseCase.dart';
import '../../domain/usecase/messaging/GetMessagesUseCase.dart';
import '../../domain/usecase/messaging/GetOrCreateConversationUseCase.dart';
import '../../domain/usecase/messaging/SendMessageUseCase.dart';
import '../../domain/usecase/messaging/MarkAsReadUseCase.dart';
import '../../data/model/MessageModel.dart';

class MessagingProvider extends ChangeNotifier {
  final GetConversationsUseCase getConversationsUseCase;
  final GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkAsReadUseCase markAsReadUseCase;

  MessagingProvider({
    required this.getConversationsUseCase,
    required this.getOrCreateConversationUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markAsReadUseCase,
  });

  // Conversations state
  List<Conversation> conversations = [];
  bool isLoadingConversations = false;
  String? conversationsError;

  // Messages state
  List<Message> messages = [];
  bool isLoadingMessages = false;
  String? messagesError;
  bool hasMore = true;
  int _page = 0;
  RealtimeChannel? _messagesChannel;
  StreamSubscription<dynamic>? _messagesStreamSub;
  bool _realtimeActive = false;

  Future<void> loadConversations() async {
    isLoadingConversations = true;
    conversationsError = null;
    notifyListeners();
    try {
      conversations = await getConversationsUseCase();
    } catch (e) {
      conversationsError = e.toString();
    } finally {
      isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<Conversation?> getOrCreateConversation(String otherUserId) async {
    try {
      final conv = await getOrCreateConversationUseCase(otherUserId);
      return conv;
    } catch (e) {
      return null;
    }
  }

  Future<void> openConversation(String conversationId) async {
    messages.clear();
    hasMore = true;
    _page = 0;
    await loadMoreMessages(conversationId, refresh: true);
  }

  Future<void> loadMoreMessages(
    String conversationId, {
    bool refresh = false,
  }) async {
    if (isLoadingMessages) return;
    if (!refresh && !hasMore) return;
    isLoadingMessages = true;
    messagesError = null;
    notifyListeners();
    try {
      if (refresh) {
        _page = 0;
        hasMore = true;
        messages.clear();
      }
      final fetched = await getMessagesUseCase(
        conversationId,
        page: _page,
        limit: 30,
      );
      if (fetched.isEmpty) {
        hasMore = false;
      } else {
        _page += 1;
        messages.addAll(fetched);
      }
    } catch (e) {
      messagesError = e.toString();
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<Message?> sendMessage(String conversationId, String content) async {
    if (content.trim().isEmpty) return null;
    try {
      final msg = await sendMessageUseCase(
        conversationId: conversationId,
        content: content.trim(),
      );
      // Nếu đang dùng realtime stream, không chèn thủ công để tránh trùng lặp
      if (!_realtimeActive) {
        final exists = messages.any((m) => m.id == msg.id);
        if (!exists) {
          messages.insert(0, msg);
          notifyListeners();
        }
      }
      return msg;
    } catch (e) {
      messagesError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> markAsRead(String messageId, String conversationId) async {
    try {
      await markAsReadUseCase(messageId, conversationId);
    } catch (_) {}
  }

  // Realtime subscription for messages in a conversation
  void subscribeToConversation(String conversationId) {
    // Unsubscribe previous channel if any
    unsubscribeFromConversation();
    final client = Supabase.instance.client;
    // Prefer reliable table stream for immediate updates
    _messagesStreamSub = client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .listen((rows) {
      try {
        final list = rows
            .map<MessageModel>((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        // sort newest first for reverse ListView
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        messages = list;
        notifyListeners();
      } catch (_) {}
    });
    _realtimeActive = true;
  }

  void unsubscribeFromConversation() {
    if (_messagesChannel != null) {
      Supabase.instance.client.removeChannel(_messagesChannel!);
      _messagesChannel = null;
    }
    _messagesStreamSub?.cancel();
    _messagesStreamSub = null;
    _realtimeActive = false;
  }
}

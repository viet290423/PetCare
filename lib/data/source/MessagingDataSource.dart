import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../model/ConversationModel.dart';
import '../model/MessageModel.dart';

abstract class MessagingDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> getOrCreateConversation(String otherUserId);
  Future<List<MessageModel>> getMessages(String conversationId, {int page = 0, int limit = 50});
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<void> markAsRead(String messageId, String conversationId);
// Nếu cần: uploadMedia tương tự community
}

class MessagingDataSourceImpl implements MessagingDataSource {
  final SupabaseClient client;
  final Uuid uuid = const Uuid();

  MessagingDataSourceImpl(this.client);

  String get _currentUserId {
    final user = client.auth.currentUser;
    if (user == null) throw ServerException(message: 'Chưa đăng nhập');
    return user.id;
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await client
          .from('conversations')
          .select()
          .contains('participants', [_currentUserId])
          .order('last_message_time', ascending: false);

      final conversations = <ConversationModel>[];
      for (final json in response) {
        // Lấy thông tin user khác (không phải current user)
        final participants = List<String>.from(json['participants']);
        final otherUserId = participants.firstWhere((id) => id != _currentUserId);
        final otherUserInfo = await _getUserProfile(otherUserId); // Tái sử dụng từ CommunityDataSource nếu có
        json['other_user_name'] = otherUserInfo['name'] ?? 'Người dùng';
        json['other_user_avatar'] = otherUserInfo['avatar_url'];

        conversations.add(ConversationModel.fromJson(json));
      }
      return conversations;
    } catch (e) {
      throw ServerException(message: 'Không thể tải cuộc trò chuyện: $e');
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation(String otherUserId) async {
    try {
      // Tìm conversation tồn tại
      final response = await client
          .from('conversations')
          .select()
          .contains('participants', [_currentUserId, otherUserId])
          .maybeSingle();

      if (response != null) {
        return ConversationModel.fromJson(response);
      }

      // Tạo mới nếu không tồn tại
      final convId = uuid.v4();
      final participants = [_currentUserId, otherUserId];
      final convData = {
        'id': convId,
        'participants': participants,
        'created_at': DateTime.now().toIso8601String(),
      };
      await client.from('conversations').insert(convData);
      return ConversationModel(
        id: convId,
        participants: participants,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(message: 'Không thể tạo cuộc trò chuyện: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId, {int page = 0, int limit = 50}) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return response.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Không thể tải tin nhắn: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({required String conversationId, required String content}) async {
    try {
      final msgId = uuid.v4();
      final msgData = {
        'id': msgId,
        'conversation_id': conversationId,
        'sender_id': _currentUserId,
        'content': content,
        'read_by': [], // Ban đầu chưa ai đọc
        'created_at': DateTime.now().toIso8601String(),
      };
      await client.from('messages').insert(msgData);

      // Cập nhật last_message cho conversation
      await client.from('conversations').update({
        'last_message': content,
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      return MessageModel.fromJson(msgData);
    } catch (e) {
      throw ServerException(message: 'Không thể gửi tin nhắn: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId, String conversationId) async {
    try {
      await client.rpc('mark_message_as_read', params: {
        'p_message_id': messageId,
        'p_user_id': _currentUserId,
      }); // Tạo RPC function trên Supabase để append _currentUserId vào read_by array
    } catch (e) {
      throw ServerException(message: 'Không thể đánh dấu đã đọc: $e');
    }
  }

  Future<Map<String, String?>> _getUserProfile(String userId) async {
    try {
      // Thử lấy từ profiles table trước
      final profileResponse = await client
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse != null && profileResponse['name'] != null && profileResponse['name'] != 'Người dùng') {
        return {
          'name': profileResponse['name'] as String?,
          'avatar_url': profileResponse['avatar_url'] as String?,
        };
      }

      // Nếu không tìm thấy hoặc tên là "Người dùng", thử lấy từ doctors table
      final doctorResponse = await client
          .from('doctors')
          .select('name, image_url')
          .eq('user_id', userId)
          .maybeSingle();

      if (doctorResponse != null) {
        return {
          'name': doctorResponse['name'] as String?,
          'avatar_url': doctorResponse['image_url'] as String?,
        };
      }

      // Fallback nếu không tìm thấy ở cả hai bảng
      return {'name': 'Người dùng', 'avatar_url': null};
    } catch (e) {
      // Fallback nếu có lỗi
      return {'name': 'Người dùng', 'avatar_url': null};
    }
  }
}
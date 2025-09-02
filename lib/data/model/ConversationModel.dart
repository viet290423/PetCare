import '../../domain/entity/Conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.participants,
    super.lastMessage,
    super.lastMessageTime,
    required super.createdAt,
    super.otherUserName,
    super.otherUserAvatar,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'other_user_name': otherUserName,
      'other_user_avatar': otherUserAvatar,
    };
  }
}
enum ConversationType { oneToOne, group } 
class Conversation {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  // Optional presentation fields for UI (resolved in data layer)
  final String? otherUserName;
  final String? otherUserAvatar;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
  });
}
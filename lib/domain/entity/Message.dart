class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final List<String> readBy;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.readBy,
    required this.createdAt,
  });
}
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final String? parentCommentId; // For nested comments/replies
  final int likesCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
    this.parentCommentId,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_display_name': userDisplayName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'parent_comment_id': parentCommentId,
      'likes_count': likesCount,
      'is_liked_by_current_user': isLikedByCurrentUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      postId: map['post_id'] ?? '',
      userId: map['user_id'] ?? '',
      userDisplayName: map['user_display_name'] ?? '',
      userAvatarUrl: map['user_avatar_url'],
      content: map['content'] ?? '',
      parentCommentId: map['parent_comment_id'],
      likesCount: map['likes_count'] ?? 0,
      isLikedByCurrentUser: map['is_liked_by_current_user'] ?? false,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? content,
    String? parentCommentId,
    int? likesCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

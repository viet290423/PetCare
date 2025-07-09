enum LikeTargetType { post, comment }

class Like {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String targetId; // postId hoặc commentId
  final LikeTargetType targetType;
  final DateTime createdAt;

  const Like({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_display_name': userDisplayName,
      'user_avatar_url': userAvatarUrl,
      'target_id': targetId,
      'target_type': targetType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      userDisplayName: map['user_display_name'] ?? '',
      userAvatarUrl: map['user_avatar_url'],
      targetId: map['target_id'] ?? '',
      targetType: LikeTargetType.values.firstWhere(
        (e) => e.name == map['target_type'],
        orElse: () => LikeTargetType.post,
      ),
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Like copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? targetId,
    LikeTargetType? targetType,
    DateTime? createdAt,
  }) {
    return Like(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

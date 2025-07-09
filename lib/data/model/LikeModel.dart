import '../../domain/entity/Like.dart';

class LikeModel extends Like {
  const LikeModel({
    required super.id,
    required super.userId,
    required super.userDisplayName,
    super.userAvatarUrl,
    required super.targetId,
    required super.targetType,
    required super.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userDisplayName: json['user_display_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      targetId: json['target_id'] as String,
      targetType: LikeTargetType.values.firstWhere(
        (e) => e.name == json['target_type'],
        orElse: () => LikeTargetType.post,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
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

  // Helper method for Supabase insert/update (excludes read-only fields)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LikeModel copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? targetId,
    LikeTargetType? targetType,
    DateTime? createdAt,
  }) {
    return LikeModel(
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

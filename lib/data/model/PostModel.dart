import '../../domain/entity/Post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userDisplayName,
    super.userAvatarUrl,
    required super.content,
    super.mediaUrls = const [],
    required super.type,
    super.privacy = PostPrivacy.public,
    super.likesCount = 0,
    super.commentsCount = 0,
    super.isLikedByCurrentUser = false,
    required super.createdAt,
    required super.updatedAt,
    super.tags = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userDisplayName: json['user_display_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String,
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : const [],
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.text,
      ),
      privacy: PostPrivacy.values.firstWhere(
        (e) => e.name == json['privacy'],
        orElse: () => PostPrivacy.public,
      ),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_display_name': userDisplayName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'media_urls': mediaUrls,
      'type': type.name,
      'privacy': privacy.name,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked_by_current_user': isLikedByCurrentUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  // Helper method for Supabase insert/update (excludes read-only fields)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'type': type.name,
      'privacy': privacy.name,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? content,
    List<String>? mediaUrls,
    PostType? type,
    PostPrivacy? privacy,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

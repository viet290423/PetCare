enum PostType { text, image, video }

enum PostPrivacy { public, friends, private }

class Post {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String content;
  final List<String> mediaUrls;
  final PostType type;
  final PostPrivacy privacy;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Post({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.content,
    this.mediaUrls = const [],
    required this.type,
    this.privacy = PostPrivacy.public,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByCurrentUser = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
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

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      userDisplayName: map['user_display_name'] ?? '',
      userAvatarUrl: map['user_avatar_url'],
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      type: PostType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PostType.text,
      ),
      privacy: PostPrivacy.values.firstWhere(
        (e) => e.name == map['privacy'],
        orElse: () => PostPrivacy.public,
      ),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      isLikedByCurrentUser: map['is_liked_by_current_user'] ?? false,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Post copyWith({
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
    return Post(
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

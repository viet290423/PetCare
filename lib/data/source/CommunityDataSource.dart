import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/exceptions.dart';
import '../../domain/entity/Post.dart';
import '../model/PostModel.dart';
import '../model/CommentModel.dart';
import '../model/LikeModel.dart';

abstract class CommunityDataSource {
  Future<List<PostModel>> getPosts({
    int page = 0,
    int limit = 20,
    String? userId,
    PostType? type,
  });

  Future<PostModel> getPostById(String postId);

  Future<PostModel> createPost({
    required String content,
    required PostType type,
    List<String> mediaUrls = const [],
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
  });

  Future<PostModel> updatePost({
    required String postId,
    String? content,
    PostPrivacy? privacy,
    List<String>? tags,
  });

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> likeComment(String commentId);
  Future<void> unlikeComment(String commentId);
  Future<List<LikeModel>> getPostLikes(String postId);
  Future<List<LikeModel>> getCommentLikes(String commentId);

  Future<List<CommentModel>> getPostComments({
    required String postId,
    int page = 0,
    int limit = 20,
  });

  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });

  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  });

  Future<void> deleteComment(String commentId);

  Future<String> uploadMedia({
    required String filePath,
    required String fileName,
    required String fileType,
  });

  Future<List<PostModel>> searchPosts({
    required String query,
    PostType? type,
    List<String>? tags,
    int page = 0,
    int limit = 20,
  });

  Future<List<String>> getTrendingTags({int limit = 10});
}

class CommunityDataSourceImpl implements CommunityDataSource {
  final SupabaseClient client;
  final Uuid uuid = const Uuid();

  CommunityDataSourceImpl(this.client);

  String get _currentUserId {
    final user = client.auth.currentUser;
    if (user == null) {
      throw ServerException(
        message: 'Bạn cần đăng nhập để thực hiện hành động này',
      );
    }
    return user.id;
  }

  Future<void> _ensureUserProfile() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return;

      // Kiểm tra xem profile đã tồn tại chưa
      final existingProfile = await client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Thử lấy tên từ doctors table trước (nếu là doctor)
        String displayName = 'Người dùng';
        String? avatarUrl;

        try {
          final doctorInfo = await client
              .from('doctors')
              .select('name, image_url')
              .eq('user_id', currentUser.id)
              .maybeSingle();

          if (doctorInfo != null) {
            displayName = doctorInfo['name'] as String? ?? 'Người dùng';
            avatarUrl = doctorInfo['image_url'] as String?;
          } else {
            // Nếu không phải doctor, lấy từ user metadata
            final metadata = currentUser.userMetadata ?? {};
            displayName = metadata['name'] ?? 'Người dùng';
          }
        } catch (e) {
          // Fallback to user metadata
          final metadata = currentUser.userMetadata ?? {};
          displayName = metadata['name'] ?? 'Người dùng';
        }

        // Tạo profile mới
        await client.from('profiles').insert({
          'id': currentUser.id,
          'name': displayName,
          'avatar_url': avatarUrl,
        });
      }
    } catch (e) {
      // Ignore errors - profile creation is not critical for posting
      print('Warning: Could not ensure user profile: $e');
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

  @override
  Future<List<PostModel>> getPosts({
    int page = 0,
    int limit = 20,
    String? userId,
    PostType? type,
  }) async {
    try {
      // Query posts trước
      var queryBuilder = client.from('posts').select().eq('privacy', 'public');

      if (userId != null) {
        queryBuilder = queryBuilder.eq('user_id', userId);
      }

      if (type != null) {
        queryBuilder = queryBuilder.eq('type', type.name);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      final posts = <PostModel>[];
      for (final json in response) {
        // Lấy thông tin user từ profiles table riêng biệt
        final postUserId = json['user_id'] as String;
        final userInfo = await _getUserProfile(postUserId);

        json['user_display_name'] = userInfo['name'] ?? 'Người dùng';
        json['user_avatar_url'] = userInfo['avatar_url'];

        // Get likes count and check if current user liked
        final likesCount = await _getPostLikesCount(json['id']);
        json['likes_count'] = likesCount;
        json['is_liked_by_current_user'] = await _isPostLikedByCurrentUser(
          json['id'],
        );

        // Get comments count
        json['comments_count'] = await _getCommentsCount(json['id']);

        posts.add(PostModel.fromJson(json));
      }

      return posts;
    } catch (e) {
      throw ServerException(message: 'Không thể tải bài viết: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      // Lấy thông tin user từ profiles table riêng biệt
      final postUserId = response['user_id'] as String;
      final userInfo = await _getUserProfile(postUserId);
      response['user_display_name'] = userInfo['name'] ?? 'Người dùng';
      response['user_avatar_url'] = userInfo['avatar_url'];

      // Get likes count and check if current user liked
      response['likes_count'] = await _getPostLikesCount(postId);
      response['is_liked_by_current_user'] = await _isPostLikedByCurrentUser(
        postId,
      );

      // Get comments count
      response['comments_count'] = await _getCommentsCount(postId);

      return PostModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Không thể tải bài viết: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> createPost({
    required String content,
    required PostType type,
    List<String> mediaUrls = const [],
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
  }) async {
    try {
      // Đảm bảo user profile tồn tại trước khi tạo post
      await _ensureUserProfile();

      final postId = uuid.v4();
      final now = DateTime.now();

      final postData = {
        'id': postId,
        'user_id': _currentUserId,
        'content': content,
        'media_urls': mediaUrls,
        'type': type.name,
        'privacy': privacy.name,
        'tags': tags,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await client.from('posts').insert(postData);
      return await getPostById(postId);
    } catch (e) {
      throw ServerException(message: 'Không thể tạo bài viết: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> updatePost({
    required String postId,
    String? content,
    PostPrivacy? privacy,
    List<String>? tags,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (content != null) updateData['content'] = content;
      if (privacy != null) updateData['privacy'] = privacy.name;
      if (tags != null) updateData['tags'] = tags;

      await client
          .from('posts')
          .update(updateData)
          .eq('id', postId)
          .eq('user_id', _currentUserId);

      return await getPostById(postId);
    } catch (e) {
      throw ServerException(
        message: 'Không thể cập nhật bài viết: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(message: 'Không thể xóa bài viết: ${e.toString()}');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final likeData = {
        'id': uuid.v4(),
        'user_id': _currentUserId,
        'target_id': postId,
        'target_type': 'post',
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('likes').insert(likeData);
    } catch (e) {
      throw ServerException(
        message: 'Không thể thích bài viết: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      await client
          .from('likes')
          .delete()
          .eq('target_id', postId)
          .eq('target_type', 'post')
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(
        message: 'Không thể bỏ thích bài viết: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> likeComment(String commentId) async {
    try {
      final likeData = {
        'id': uuid.v4(),
        'user_id': _currentUserId,
        'target_id': commentId,
        'target_type': 'comment',
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('likes').insert(likeData);
    } catch (e) {
      throw ServerException(
        message: 'Không thể thích bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    try {
      await client
          .from('likes')
          .delete()
          .eq('target_id', commentId)
          .eq('target_type', 'comment')
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(
        message: 'Không thể bỏ thích bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<LikeModel>> getPostLikes(String postId) async {
    try {
      final response = await client
          .from('likes')
          .select()
          .eq('target_id', postId)
          .eq('target_type', 'post')
          .order('created_at', ascending: false);

      return response.map((json) {
        json['user_display_name'] = 'Người dùng';
        json['user_avatar_url'] = null;
        return LikeModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Không thể tải danh sách thích: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<LikeModel>> getCommentLikes(String commentId) async {
    try {
      final response = await client
          .from('likes')
          .select()
          .eq('target_id', commentId)
          .eq('target_type', 'comment')
          .order('created_at', ascending: false);

      return response.map((json) {
        json['user_display_name'] = 'Người dùng';
        json['user_avatar_url'] = null;
        return LikeModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Không thể tải danh sách thích: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<CommentModel>> getPostComments({
    required String postId,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true)
          .range(page * limit, (page + 1) * limit - 1);

      final comments = <CommentModel>[];
      for (final json in response) {
        // Lấy thông tin user từ profiles table riêng biệt
        final commentUserId = json['user_id'] as String;
        final userInfo = await _getUserProfile(commentUserId);
        json['user_display_name'] = userInfo['name'] ?? 'Người dùng';
        json['user_avatar_url'] = userInfo['avatar_url'];

        json['likes_count'] = await _getCommentLikesCount(json['id']);
        json['is_liked_by_current_user'] = await _isCommentLikedByCurrentUser(
          json['id'],
        );

        comments.add(CommentModel.fromJson(json));
      }

      return comments;
    } catch (e) {
      throw ServerException(
        message: 'Không thể tải bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      // Đảm bảo user profile tồn tại trước khi tạo comment
      await _ensureUserProfile();

      final commentId = uuid.v4();
      final now = DateTime.now();

      final commentData = {
        'id': commentId,
        'post_id': postId,
        'user_id': _currentUserId,
        'content': content,
        'parent_comment_id': parentCommentId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await client.from('comments').insert(commentData);

      final response = await client
          .from('comments')
          .select()
          .eq('id', commentId)
          .single();

      // Lấy thông tin user từ profiles table riêng biệt
      final commentUserId = response['user_id'] as String;
      final userInfo = await _getUserProfile(commentUserId);
      response['user_display_name'] = userInfo['name'] ?? 'Người dùng';
      response['user_avatar_url'] = userInfo['avatar_url'];
      response['likes_count'] = 0;
      response['is_liked_by_current_user'] = false;

      return CommentModel.fromJson(response);
    } catch (e) {
      throw ServerException(
        message: 'Không thể tạo bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      await client
          .from('comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .eq('user_id', _currentUserId);

      final response = await client
          .from('comments')
          .select()
          .eq('id', commentId)
          .single();

      // Lấy thông tin user từ profiles table riêng biệt
      final commentUserId = response['user_id'] as String;
      final userInfo = await _getUserProfile(commentUserId);
      response['user_display_name'] = userInfo['name'] ?? 'Người dùng';
      response['user_avatar_url'] = userInfo['avatar_url'];
      response['likes_count'] = await _getCommentLikesCount(commentId);
      response['is_liked_by_current_user'] = await _isCommentLikedByCurrentUser(
        commentId,
      );

      return CommentModel.fromJson(response);
    } catch (e) {
      throw ServerException(
        message: 'Không thể cập nhật bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(
        message: 'Không thể xóa bình luận: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> uploadMedia({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ServerException(message: 'File không tồn tại');
      }

      final fileBytes = await file.readAsBytes();
      final storageFileName = '${_currentUserId}/${uuid.v4()}_$fileName';

      await client.storage
          .from('community-media')
          .uploadBinary(storageFileName, fileBytes);

      final publicUrl = client.storage
          .from('community-media')
          .getPublicUrl(storageFileName);

      return publicUrl;
    } catch (e) {
      print("Error uploading media: ${e.toString()}");
      throw ServerException(
        message: 'Không thể tải lên media: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PostModel>> searchPosts({
    required String query,
    PostType? type,
    List<String>? tags,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = client
          .from('posts')
          .select()
          .eq('privacy', 'public')
          .ilike('content', '%$query%');

      if (type != null) {
        queryBuilder = queryBuilder.eq('type', type.name);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      final posts = <PostModel>[];
      for (final json in response) {
        // Lấy thông tin user từ profiles table riêng biệt
        final postUserId = json['user_id'] as String;
        final userInfo = await _getUserProfile(postUserId);
        json['user_display_name'] = userInfo['name'] ?? 'Người dùng';
        json['user_avatar_url'] = userInfo['avatar_url'];

        json['likes_count'] = await _getPostLikesCount(json['id']);
        json['is_liked_by_current_user'] = await _isPostLikedByCurrentUser(
          json['id'],
        );

        json['comments_count'] = await _getCommentsCount(json['id']);

        posts.add(PostModel.fromJson(json));
      }

      return posts;
    } catch (e) {
      throw ServerException(
        message: 'Không thể tìm kiếm bài viết: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getTrendingTags({int limit = 10}) async {
    try {
      final response = await client
          .from('posts')
          .select('tags')
          .eq('privacy', 'public')
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          )
          .limit(1000);

      final Map<String, int> tagCounts = {};

      for (final post in response) {
        final tags = post['tags'] as List?;
        if (tags != null) {
          for (final tag in tags) {
            if (tag is String && tag.isNotEmpty) {
              tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
            }
          }
        }
      }

      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      throw ServerException(
        message: 'Không thể tải trending tags: ${e.toString()}',
      );
    }
  }

  // Helper methods
  Future<int> _getPostLikesCount(String postId) async {
    try {
      final response = await client
          .from('likes')
          .select('id')
          .eq('target_id', postId)
          .eq('target_type', 'post');
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> _isPostLikedByCurrentUser(String postId) async {
    try {
      final response = await client
          .from('likes')
          .select('id')
          .eq('target_id', postId)
          .eq('target_type', 'post')
          .eq('user_id', _currentUserId)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getCommentsCount(String postId) async {
    try {
      final response = await client
          .from('comments')
          .select('id')
          .eq('post_id', postId);
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getCommentLikesCount(String commentId) async {
    try {
      final response = await client
          .from('likes')
          .select('id')
          .eq('target_id', commentId)
          .eq('target_type', 'comment');
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> _isCommentLikedByCurrentUser(String commentId) async {
    try {
      final response = await client
          .from('likes')
          .select('id')
          .eq('target_id', commentId)
          .eq('target_type', 'comment')
          .eq('user_id', _currentUserId)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

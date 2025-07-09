import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entity/Post.dart';
import '../entity/Comment.dart';
import '../entity/Like.dart';

abstract class CommunityRepository {
  // Post operations
  Future<Either<Failure, List<Post>>> getPosts({
    int page = 0,
    int limit = 20,
    String? userId,
    PostType? type,
  });

  Future<Either<Failure, Post>> getPostById(String postId);

  Future<Either<Failure, Post>> createPost({
    required String content,
    required PostType type,
    List<String> mediaUrls = const [],
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
  });

  Future<Either<Failure, Post>> updatePost({
    required String postId,
    String? content,
    PostPrivacy? privacy,
    List<String>? tags,
  });

  Future<Either<Failure, void>> deletePost(String postId);

  // Like operations
  Future<Either<Failure, void>> likePost(String postId);

  Future<Either<Failure, void>> unlikePost(String postId);

  Future<Either<Failure, void>> likeComment(String commentId);

  Future<Either<Failure, void>> unlikeComment(String commentId);

  Future<Either<Failure, List<Like>>> getPostLikes(String postId);

  Future<Either<Failure, List<Like>>> getCommentLikes(String commentId);

  // Comment operations
  Future<Either<Failure, List<Comment>>> getPostComments({
    required String postId,
    int page = 0,
    int limit = 20,
  });

  Future<Either<Failure, Comment>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });

  Future<Either<Failure, Comment>> updateComment({
    required String commentId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment(String commentId);

  // Media upload
  Future<Either<Failure, String>> uploadMedia({
    required String filePath,
    required String fileName,
    required String fileType,
  });

  // Search and filter
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    PostType? type,
    List<String>? tags,
    int page = 0,
    int limit = 20,
  });

  Future<Either<Failure, List<String>>> getTrendingTags({int limit = 10});
}

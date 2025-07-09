import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entity/Post.dart';
import '../../domain/entity/Comment.dart';
import '../../domain/entity/Like.dart';
import '../../domain/repository/CommunityRepository.dart';
import '../source/CommunityDataSource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityDataSource dataSource;

  CommunityRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Post>>> getPosts({
    int page = 0,
    int limit = 20,
    String? userId,
    PostType? type,
  }) async {
    try {
      final posts = await dataSource.getPosts(
        page: page,
        limit: limit,
        userId: userId,
        type: type,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(String postId) async {
    try {
      final post = await dataSource.getPostById(postId);
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost({
    required String content,
    required PostType type,
    List<String> mediaUrls = const [],
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
  }) async {
    try {
      final post = await dataSource.createPost(
        content: content,
        type: type,
        mediaUrls: mediaUrls,
        privacy: privacy,
        tags: tags,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, Post>> updatePost({
    required String postId,
    String? content,
    PostPrivacy? privacy,
    List<String>? tags,
  }) async {
    try {
      final post = await dataSource.updatePost(
        postId: postId,
        content: content,
        privacy: privacy,
        tags: tags,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await dataSource.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId) async {
    try {
      await dataSource.likePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId) async {
    try {
      await dataSource.unlikePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> likeComment(String commentId) async {
    try {
      await dataSource.likeComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeComment(String commentId) async {
    try {
      await dataSource.unlikeComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<Like>>> getPostLikes(String postId) async {
    try {
      final likes = await dataSource.getPostLikes(postId);
      return Right(likes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<Like>>> getCommentLikes(String commentId) async {
    try {
      final likes = await dataSource.getCommentLikes(commentId);
      return Right(likes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getPostComments({
    required String postId,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final comments = await dataSource.getPostComments(
        postId: postId,
        page: page,
        limit: limit,
      );
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, Comment>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = await dataSource.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final comment = await dataSource.updateComment(
        commentId: commentId,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await dataSource.deleteComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadMedia({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    try {
      final url = await dataSource.uploadMedia(
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts({
    required String query,
    PostType? type,
    List<String>? tags,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final posts = await dataSource.searchPosts(
        query: query,
        type: type,
        tags: tags,
        page: page,
        limit: limit,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTrendingTags({
    int limit = 10,
  }) async {
    try {
      final tags = await dataSource.getTrendingTags(limit: limit);
      return Right(tags);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}

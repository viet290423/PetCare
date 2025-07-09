import 'package:dartz/dartz.dart';

import '../../entity/Comment.dart';
import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class CreateCommentUseCase {
  final CommunityRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Either<Failure, Comment>> call({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    // Validate postId
    if (postId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID bài viết không hợp lệ'));
    }

    // Validate content
    if (content.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'Nội dung bình luận không được để trống'),
      );
    }

    if (content.length > 1000) {
      return Left(
        ValidationFailure(
          message: 'Nội dung bình luận không được vượt quá 1000 ký tự',
        ),
      );
    }

    return await repository.createComment(
      postId: postId,
      content: content.trim(),
      parentCommentId: parentCommentId,
    );
  }
}

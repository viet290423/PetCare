import 'package:dartz/dartz.dart';

import '../../entity/Comment.dart';
import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class GetPostCommentsUseCase {
  final CommunityRepository repository;

  GetPostCommentsUseCase(this.repository);

  Future<Either<Failure, List<Comment>>> call({
    required String postId,
    int page = 0,
    int limit = 20,
  }) async {
    if (postId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID bài viết không hợp lệ'));
    }

    return await repository.getPostComments(
      postId: postId,
      page: page,
      limit: limit,
    );
  }
}

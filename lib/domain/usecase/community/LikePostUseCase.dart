import 'package:dartz/dartz.dart';

import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class LikePostUseCase {
  final CommunityRepository repository;

  LikePostUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String postId,
    required bool isLiked,
  }) async {
    if (postId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID bài viết không hợp lệ'));
    }

    if (isLiked) {
      return await repository.unlikePost(postId);
    } else {
      return await repository.likePost(postId);
    }
  }
}

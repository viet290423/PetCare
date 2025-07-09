import 'package:dartz/dartz.dart';

import '../../entity/Post.dart';
import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class GetPostsUseCase {
  final CommunityRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call({
    int page = 0,
    int limit = 20,
    String? userId,
    PostType? type,
  }) async {
    return await repository.getPosts(
      page: page,
      limit: limit,
      userId: userId,
      type: type,
    );
  }
}

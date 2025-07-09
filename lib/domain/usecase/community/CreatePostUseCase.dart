import 'package:dartz/dartz.dart';

import '../../entity/Post.dart';
import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class CreatePostUseCase {
  final CommunityRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, Post>> call({
    required String content,
    required PostType type,
    List<String> mediaUrls = const [],
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'Nội dung bài viết không được để trống'),
      );
    }

    if (content.length > 5000) {
      return Left(
        ValidationFailure(
          message: 'Nội dung bài viết không được vượt quá 5000 ký tự',
        ),
      );
    }

    // Validate media URLs for image and video posts
    if (type != PostType.text && mediaUrls.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Bài viết hình ảnh/video cần có ít nhất một file media',
        ),
      );
    }

    if (mediaUrls.length > 10) {
      return Left(
        ValidationFailure(
          message: 'Không thể đăng quá 10 file media trong một bài viết',
        ),
      );
    }

    // Validate tags
    if (tags.length > 10) {
      return Left(
        ValidationFailure(
          message: 'Không thể có quá 10 tags trong một bài viết',
        ),
      );
    }

    return await repository.createPost(
      content: content,
      type: type,
      mediaUrls: mediaUrls,
      privacy: privacy,
      tags: tags,
    );
  }
}

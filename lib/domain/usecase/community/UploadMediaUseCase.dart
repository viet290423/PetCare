import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../repository/CommunityRepository.dart';
import '../../../core/error/failures.dart';

class UploadMediaUseCase {
  final CommunityRepository repository;

  UploadMediaUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    // Validate file path
    if (filePath.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Đường dẫn file không hợp lệ'));
    }

    // Check if file exists
    final file = File(filePath);
    if (!await file.exists()) {
      return Left(ValidationFailure(message: 'File không tồn tại'));
    }

    // Validate file name
    if (fileName.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Tên file không hợp lệ'));
    }

    // Validate file type
    final allowedTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'video/mp4',
      'video/mov',
      'video/avi',
    ];
    if (!allowedTypes.contains(fileType.toLowerCase())) {
      return Left(
        ValidationFailure(
          message:
              'Loại file không được hỗ trợ. Chỉ hỗ trợ ảnh (JPG, PNG, GIF) và video (MP4, MOV, AVI)',
        ),
      );
    }

    // Check file size (max 50MB)
    final fileSize = await file.length();
    const maxSize = 50 * 1024 * 1024; // 50MB
    if (fileSize > maxSize) {
      return Left(
        ValidationFailure(message: 'File quá lớn. Kích thước tối đa là 50MB'),
      );
    }

    return await repository.uploadMedia(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );
  }
}

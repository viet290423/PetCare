import 'package:flutter/material.dart';

import '../../domain/entity/Post.dart';
import '../../domain/entity/Comment.dart';
import '../../domain/usecase/community/GetPostsUseCase.dart';
import '../../domain/usecase/community/CreatePostUseCase.dart';
import '../../domain/usecase/community/LikePostUseCase.dart';
import '../../domain/usecase/community/CreateCommentUseCase.dart';
import '../../domain/usecase/community/GetPostCommentsUseCase.dart';
import '../../domain/usecase/community/UploadMediaUseCase.dart';

class CommunityProvider with ChangeNotifier {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final LikePostUseCase likePostUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final UploadMediaUseCase uploadMediaUseCase;

  CommunityProvider({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.likePostUseCase,
    required this.createCommentUseCase,
    required this.getPostCommentsUseCase,
    required this.uploadMediaUseCase,
  });

  // Posts state
  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  String? _postsError;
  int _currentPage = 0;
  bool _hasMorePosts = true;

  // Create post state
  bool _isCreatingPost = false;
  String? _createPostError;
  List<String> _uploadedMediaUrls = [];
  bool _isUploadingMedia = false;

  // Comments state
  Map<String, List<Comment>> _postComments = {};
  bool _isLoadingComments = false;
  String? _commentsError;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingMorePosts => _isLoadingMorePosts;
  String? get postsError => _postsError;
  bool get hasMorePosts => _hasMorePosts;

  bool get isCreatingPost => _isCreatingPost;
  String? get createPostError => _createPostError;
  List<String> get uploadedMediaUrls => _uploadedMediaUrls;
  bool get isUploadingMedia => _isUploadingMedia;

  Map<String, List<Comment>> get postComments => _postComments;
  bool get isLoadingComments => _isLoadingComments;
  String? get commentsError => _commentsError;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Load initial posts
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMorePosts = true;
      _posts.clear();
    }

    if (_isLoadingPosts || !_hasMorePosts) return;

    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    final result = await getPostsUseCase(page: _currentPage, limit: 20);

    result.fold(
      (failure) {
        _postsError = failure.message ?? 'Không thể tải bài viết';
        _hasMorePosts = false;
      },
      (newPosts) {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        
        _hasMorePosts = newPosts.length == 20;
        _currentPage++;
        _postsError = null;
      },
    );

    _isLoadingPosts = false;
    notifyListeners();
  }

  // Load more posts
  Future<void> loadMorePosts() async {
    if (_isLoadingMorePosts || !_hasMorePosts) return;

    _isLoadingMorePosts = true;
    notifyListeners();

    final result = await getPostsUseCase(page: _currentPage, limit: 20);

    result.fold(
      (failure) {
        _postsError = failure.message ?? 'Không thể tải thêm bài viết';
        _hasMorePosts = false;
      },
      (newPosts) {
        _posts.addAll(newPosts);
        _hasMorePosts = newPosts.length == 20;
        _currentPage++;
        _postsError = null;
      },
    );

    _isLoadingMorePosts = false;
    notifyListeners();
  }

  // Create new post
  Future<void> createPost({
    required String content,
    required PostType type,
    PostPrivacy privacy = PostPrivacy.public,
    List<String> tags = const [],
    required BuildContext context,
  }) async {
    _isCreatingPost = true;
    _createPostError = null;
    notifyListeners();

    final result = await createPostUseCase(
      content: content,
      type: type,
      mediaUrls: _uploadedMediaUrls,
      privacy: privacy,
      tags: tags,
    );

    result.fold(
      (failure) {
        _createPostError = failure.message ?? 'Không thể tạo bài viết';
        _showError(context, _createPostError!);
      },
      (post) {
        _posts.insert(0, post);
        _uploadedMediaUrls.clear();
        _createPostError = null;
        _showSuccess(context, 'Đăng bài thành công!');
      },
    );

    _isCreatingPost = false;
    notifyListeners();
  }

  // Upload media
  Future<void> uploadMedia({
    required String filePath,
    required String fileName,
    required String fileType,
    required BuildContext context,
  }) async {
    _isUploadingMedia = true;
    notifyListeners();

    final result = await uploadMediaUseCase(
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
    );

    result.fold(
      (failure) {
        _showError(context, failure.message ?? 'Không thể tải lên file');
      },
      (url) {
        _uploadedMediaUrls.add(url);
        _showSuccess(context, 'Tải lên thành công!');
      },
    );

    _isUploadingMedia = false;
    notifyListeners();
  }

  // Remove uploaded media
  void removeUploadedMedia(String url) {
    _uploadedMediaUrls.remove(url);
    notifyListeners();
  }

  // Clear uploaded media
  void clearUploadedMedia() {
    _uploadedMediaUrls.clear();
    notifyListeners();
  }

  // Like/Unlike post
  Future<void> toggleLikePost({
    required String postId,
    required BuildContext context,
  }) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isCurrentlyLiked = post.isLikedByCurrentUser;

    // Optimistic update
    final updatedPost = post.copyWith(
      isLikedByCurrentUser: !isCurrentlyLiked,
      likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    _posts[postIndex] = updatedPost;
    notifyListeners();

    final result = await likePostUseCase(
      postId: postId,
      isLiked: isCurrentlyLiked,
    );

    result.fold(
      (failure) {
        // Revert optimistic update on error
        _posts[postIndex] = post;
        _showError(context, failure.message ?? 'Có lỗi xảy ra');
        notifyListeners();
      },
      (_) {
        // Success - optimistic update already applied
      },
    );
  }

  // Load comments for a post
  Future<void> loadPostComments({
    required String postId,
    bool refresh = false,
  }) async {
    if (_isLoadingComments) return;

    _isLoadingComments = true;
    _commentsError = null;
    notifyListeners();

    final result = await getPostCommentsUseCase(
      postId: postId,
      page: 0,
      limit: 50,
    );

    result.fold(
      (failure) {
        _commentsError = failure.message ?? 'Không thể tải bình luận';
      },
      (comments) {
        _postComments[postId] = comments;
        _commentsError = null;
      },
    );

    _isLoadingComments = false;
    notifyListeners();
  }

  // Create comment
  Future<void> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    required BuildContext context,
  }) async {
    final result = await createCommentUseCase(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );

    result.fold(
      (failure) {
        _showError(context, failure.message ?? 'Không thể tạo bình luận');
      },
      (comment) {
        // Add comment to the list
        if (_postComments[postId] != null) {
          _postComments[postId]!.add(comment);
        } else {
          _postComments[postId] = [comment];
        }

        // Update comments count in the post
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          _posts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }

        _showSuccess(context, 'Bình luận thành công!');
        notifyListeners();
      },
    );
  }

  // Get comments for a specific post
  List<Comment> getCommentsForPost(String postId) {
    return _postComments[postId] ?? [];
  }

  // Clear all data (for logout)
  void clearData() {
    _posts.clear();
    _postComments.clear();
    _uploadedMediaUrls.clear();
    _currentPage = 0;
    _hasMorePosts = true;
    _isLoadingPosts = false;
    _isLoadingMorePosts = false;
    _isCreatingPost = false;
    _isLoadingComments = false;
    _isUploadingMedia = false;
    _postsError = null;
    _createPostError = null;
    _commentsError = null;
    notifyListeners();
  }
} 
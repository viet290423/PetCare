import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entity/Post.dart';
import '../../../provider/CommunityProvider.dart';
import 'PostDetailSheet.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  backgroundImage: post.userAvatarUrl != null
                      ? NetworkImage(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userDisplayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTime(post.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildPrivacyIndicator(),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(context),
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),

          // Media content
          if (post.mediaUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildMediaContent(),
            ),

          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: post.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildLikeButton(context),
                const SizedBox(width: 24),
                _buildCommentButton(context),
                const SizedBox(width: 24),
                _buildShareButton(context),
              ],
            ),
          ),

          // Like and comment counts
          if (post.likesCount > 0 || post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.likesCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${post.likesCount} lượt thích',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (post.commentsCount > 0)
                    InkWell(
                      onTap: () => _showPostDetail(context),
                      child: Text(
                        'Xem tất cả ${post.commentsCount} bình luận',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (post.mediaUrls.isEmpty) return const SizedBox.shrink();

    if (post.type == PostType.image) {
      return _buildImageGrid();
    } else if (post.type == PostType.video) {
      return _buildVideoPlayer();
    }

    return const SizedBox.shrink();
  }

  Widget _buildImageGrid() {
    if (post.mediaUrls.length == 1) {
      // Single image - show with original aspect ratio
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
        child: Image.network(
          post.mediaUrls.first,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Multiple images - show in grid
    return SizedBox(
      height: 300,
      child: post.mediaUrls.length == 2
          ? _buildTwoImageGrid()
          : post.mediaUrls.length == 3
          ? _buildThreeImageGrid()
          : _buildFourPlusImageGrid(),
    );
  }

  Widget _buildTwoImageGrid() {
    return Row(
      children: [
        for (int i = 0; i < 2; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == 0 ? 2 : 0),
              child: Image.network(
                post.mediaUrls[i],
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThreeImageGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 2),
            child: Image.network(
              post.mediaUrls[0],
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              for (int i = 1; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: i == 1 ? 2 : 0),
                    child: Image.network(
                      post.mediaUrls[i],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourPlusImageGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < 2; i++)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 0 ? 2 : 0),
                    child: Image.network(
                      post.mediaUrls[i],
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  child: Image.network(
                    post.mediaUrls[2],
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
                      post.mediaUrls[3],
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (post.mediaUrls.length > 4)
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Text(
                            '+${post.mediaUrls.length - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Video thumbnail (if available)
          Container(width: double.infinity, height: 250, color: Colors.black),
          // Play button
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
          ),
          // Duration badge (if available)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '0:30',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final provider = Provider.of<CommunityProvider>(context, listen: false);
        provider.toggleLikePost(postId: post.id, context: context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
          color: post.isLikedByCurrentUser ? Colors.red : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return InkWell(
      onTap: () => _showPostDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 24),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return InkWell(
      onTap: () => _showShareOptions(context),
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.share_outlined, color: Colors.grey, size: 24),
      ),
    );
  }

  Widget _buildPrivacyIndicator() {
    IconData icon;
    Color color = Colors.grey[600]!;

    switch (post.privacy) {
      case PostPrivacy.private:
        icon = Icons.lock;
        break;
      case PostPrivacy.friends:
        icon = Icons.people;
        break;
      default:
        icon = Icons.public;
    }

    return Icon(icon, color: color, size: 14);
  }

  void _showPostDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailSheet(post: post),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Lưu bài viết'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Sao chép liên kết'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Báo cáo'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chia sẻ bài viết',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Tin nhắn'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Sao chép liên kết'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút';
    } else {
      return 'Vừa xong';
    }
  }
}

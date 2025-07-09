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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildPostTypeChip(),
              ],
            ),
          ),

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),

          // Media content
          if (post.mediaUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildMediaContent(),
            ),

          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildLikeButton(context),
                const SizedBox(width: 16),
                _buildCommentButton(context),
                const Spacer(),
                _buildPrivacyIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeChip() {
    Color color;
    IconData icon;
    String label;

    switch (post.type) {
      case PostType.image:
        color = Colors.blue;
        icon = Icons.image;
        label = 'Hình ảnh';
        break;
      case PostType.video:
        color = Colors.red;
        icon = Icons.videocam;
        label = 'Video';
        break;
      default:
        color = Colors.green;
        icon = Icons.text_fields;
        label = 'Văn bản';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.mediaUrls.first,
          height: 200,
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

    // Multiple images
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaUrls.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            right: index < post.mediaUrls.length - 1 ? 8 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.mediaUrls[index],
              height: 200,
              width: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: 150,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Placeholder for video player
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              post.isLikedByCurrentUser
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: post.isLikedByCurrentUser ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              post.likesCount.toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return InkWell(
      onTap: () => _showPostDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 4),
            Text(
              post.commentsCount.toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyIndicator() {
    IconData icon;
    String tooltip;

    switch (post.privacy) {
      case PostPrivacy.private:
        icon = Icons.lock;
        tooltip = 'Riêng tư';
        break;
      case PostPrivacy.friends:
        icon = Icons.people;
        tooltip = 'Bạn bè';
        break;
      default:
        icon = Icons.public;
        tooltip = 'Công khai';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: Colors.grey[400], size: 16),
    );
  }

  void _showPostDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDetailSheet(post: post),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

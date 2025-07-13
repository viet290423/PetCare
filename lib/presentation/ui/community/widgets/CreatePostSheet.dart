import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../domain/entity/Post.dart';
import '../../../provider/CommunityProvider.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  PostType _selectedType = PostType.text;
  PostPrivacy _selectedPrivacy = PostPrivacy.public;
  bool _showTagsInput = false;

  // Media handling
  List<String> _selectedMediaPaths = [];
  List<String> _selectedMediaTypes = []; // 'image' or 'video'

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMediaPaths.removeAt(index);
      _selectedMediaTypes.removeAt(index);

      // Reset type if no media left
      if (_selectedMediaPaths.isEmpty) {
        _selectedType = PostType.text;
      }
    });
  }

  Future<String?> _uploadSingleMedia(String filePath, String fileType) async {
    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      final file = File(filePath);

      // Get file extension
      final String extension = filePath.split('.').last.toLowerCase();

      // Generate unique filename
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Convert to proper MIME type
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'mp4':
          mimeType = 'video/mp4';
          break;
        case 'mov':
          mimeType = 'video/mov';
          break;
        case 'avi':
          mimeType = 'video/avi';
          break;
        default:
          // Fallback based on fileType parameter
          if (fileType == 'image') {
            mimeType = 'image/jpeg';
          } else if (fileType == 'video') {
            mimeType = 'video/mp4';
          } else {
            mimeType = 'application/octet-stream';
          }
      }

      // Upload media directly using provider's uploadMedia method
      final result = await provider.uploadMedia(
        filePath: filePath,
        fileName: fileName,
        fileType: mimeType,
        context: context,
      );

      // Return the uploaded URL (assuming provider returns it)
      return provider.uploadedMediaUrls.isNotEmpty
          ? provider.uploadedMediaUrls.last
          : null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload media: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const Expanded(
                  child: Text(
                    'Tạo bài viết',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Consumer<CommunityProvider>(
                  builder: (context, provider, child) {
                    return TextButton(
                      onPressed: provider.isCreatingPost ? null : _submitPost,
                      child: provider.isCreatingPost
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            )
                          : const Text(
                              'Đăng',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Người dùng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildPrivacySelector(),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Content input
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Bạn đang nghĩ gì về thú cưng?',
                      hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 16),

                  // Media preview section
                  if (_selectedMediaPaths.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedType == PostType.image
                                    ? Icons.image
                                    : Icons.videocam,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedType == PostType.image
                                    ? 'Hình ảnh'
                                    : 'Video',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedMediaPaths.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final path = entry.value;
                              final type = _selectedMediaTypes[index];

                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: type == 'image'
                                        ? Image.file(
                                            File(path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.play_circle_filled,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeMedia(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags input (conditionally shown)
                  if (_showTagsInput) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tag,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tags',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showTagsInput = false;
                                    _tagsController.clear();
                                  });
                                },
                                icon: const Icon(Icons.close, size: 20),
                              ),
                            ],
                          ),
                          TextField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              hintText: 'Thêm tags (phân cách bằng dấu phẩy)',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thêm vào bài viết của bạn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _buildActionItem(
                              icon: Icons.photo_library,
                              label: 'Ảnh/Video',
                              color: Colors.green,
                              onTap: () => _showMediaPicker(),
                            ),
                            const SizedBox(height: 4),
                            _buildActionItem(
                              icon: Icons.tag,
                              label: 'Tag bạn bè',
                              color: Colors.blue,
                              onTap: () {
                                setState(() {
                                  _showTagsInput = !_showTagsInput;
                                });
                              },
                            ),
                            const SizedBox(height: 4),
                            _buildActionItem(
                              icon: Icons.mood,
                              label: 'Cảm xúc/Hoạt động',
                              color: Colors.orange,
                              onTap: () {
                                // TODO: Implement mood/activity selector
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tính năng sẽ được thêm vào sau',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            _buildActionItem(
                              icon: Icons.location_on,
                              label: 'Check in',
                              color: Colors.red,
                              onTap: () {
                                // TODO: Implement location selector
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tính năng sẽ được thêm vào sau',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<PostPrivacy>(
        value: _selectedPrivacy,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPrivacy = value;
            });
          }
        },
        underline: Container(),
        items: [
          DropdownMenuItem(
            value: PostPrivacy.public,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Công khai',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: PostPrivacy.friends,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Bạn bè',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: PostPrivacy.private,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Riêng tư',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn loại media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Ảnh từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Video từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.orange),
              title: const Text('Quay video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedType = PostType.image;
          _selectedMediaPaths.add(image.path);
          _selectedMediaTypes.add('image');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedType = PostType.image;
          _selectedMediaPaths.add(image.path);
          _selectedMediaTypes.add('image');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chụp ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        setState(() {
          _selectedType = PostType.video;
          _selectedMediaPaths.add(video.path);
          _selectedMediaTypes.add('video');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        setState(() {
          _selectedType = PostType.video;
          _selectedMediaPaths.add(video.path);
          _selectedMediaTypes.add('video');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi quay video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitPost() async {
    final content = _contentController.text.trim();
    final tagsText = _tagsController.text.trim();

    if (content.isEmpty && _selectedMediaPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung hoặc thêm hình ảnh/video'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tags = tagsText.isNotEmpty
        ? tagsText
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList()
        : <String>[];

    final provider = Provider.of<CommunityProvider>(context, listen: false);

    try {
      // Upload media first if there are any
      List<String> uploadedUrls = [];
      if (_selectedMediaPaths.isNotEmpty) {
        for (int i = 0; i < _selectedMediaPaths.length; i++) {
          final path = _selectedMediaPaths[i];
          final type = _selectedMediaTypes[i];

          // Upload media and get URL
          final uploadResult = await _uploadSingleMedia(path, type);
          if (uploadResult != null) {
            uploadedUrls.add(uploadResult);
          }
        }
      }

      // Set uploaded URLs to provider for createPost
      provider.setUploadedMediaUrls(uploadedUrls);

      // Create post
      await provider.createPost(
        content: content,
        type: _selectedType,
        privacy: _selectedPrivacy,
        tags: tags,
        context: context,
      );

      if (!provider.isCreatingPost && provider.createPostError == null) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng bài: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

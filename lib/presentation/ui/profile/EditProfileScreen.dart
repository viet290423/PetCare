import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/AuthViewModel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _pickedImage;
  bool _isSaving = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    _nameController.text = auth.user?.name ?? '';
    _loadCurrentAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentAvatar() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      final data = await client
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      String? url = data?['avatar_url'] as String?;
      // Fallback from auth metadata if not found in profiles
      url ??= (user.userMetadata?['avatar_url'] as String?);
      if (!mounted) return;
      setState(() => _currentAvatarUrl = url);
    } catch (e) {
      // ignore errors, just keep null
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadAvatar(File file) async {
    try {
      final client = Supabase.instance.client;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storagePath = 'avatars/$fileName';
      final bytes = await file.readAsBytes();
      final response = await client.storage
          .from('user-avatars')
          .uploadBinary(storagePath, bytes, fileOptions: const FileOptions(upsert: false));
      if (response.isEmpty) throw Exception('Không thể upload ảnh');
      return client.storage.from('user-avatars').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final client = Supabase.instance.client;
    try {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      String? avatarUrl;
      if (_pickedImage != null) {
        final uploadedUrl = await _uploadAvatar(_pickedImage!);
        if (uploadedUrl != null) {
          avatarUrl = uploadedUrl;
        }
      }

      final updates = <String, dynamic>{'name': _nameController.text.trim()};
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      // Update if exists, otherwise insert (avoids RLS issues with generic upsert)
      final existing = await client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        await client.from('profiles').update(updates).eq('id', user.id);
      } else {
        await client.from('profiles').insert({
          'id': user.id,
          ...updates,
        });
      }

      // Update auth user metadata (optional but useful to keep in sync)
      final newMetadata = Map<String, dynamic>.from(user.userMetadata ?? {});
      newMetadata['name'] = _nameController.text.trim();
      if (avatarUrl != null) newMetadata['avatar_url'] = avatarUrl;
      await client.auth.updateUser(UserAttributes(data: newMetadata));

      // Refresh local VM state
      await auth.checkCurrentUser();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                            ? NetworkImage(_currentAvatarUrl!)
                            : null) as ImageProvider<Object>?,
                    child: (_pickedImage == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                        ? Icon(Icons.person, color: Colors.grey[500], size: 48)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        onTap: _pickImage,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.green, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



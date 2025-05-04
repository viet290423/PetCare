import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:provider/provider.dart';

import '../doctor/DoctorHomeScreen.dart';
import '../main/MainScreen.dart';
import '../user/UserHomeScreen.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomTextField.dart';
import '../widget/HeaderSection.dart';
import '../widget/NavigationLink.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _role = 'user'; // Mặc định là user

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hiển thị dialog để chọn vai trò
  Future<String?> _showRoleSelectionDialog() async {
    String? selectedRole;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn vai trò'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Người dùng'),
                onTap: () {
                  selectedRole = 'user';
                  Navigator.pop(context, 'user');
                },
              ),
              ListTile(
                title: const Text('Bác sĩ'),
                onTap: () {
                  selectedRole = 'doctor';
                  Navigator.pop(context, 'doctor');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          // Chuyển hướng sau khi đăng ký thành công
          if (viewModel.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => MainScreen(user: viewModel.user!),
                ),
                (route) => false,
              );
            });
          }

          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Tiêu đề và logo
                      const HeaderSection(title: 'Đăng ký tài khoản'),

                      // Form đăng ký
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Trường Tên
                            CustomTextField(
                              hintText: 'Tên',
                              prefixIcon: Icons.person,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 15),

                            // Trường Email
                            CustomTextField(
                              hintText: 'Email',
                              prefixIcon: Icons.email,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 15),

                            // Trường Mật khẩu
                            CustomTextField(
                              hintText: 'Mật khẩu',
                              prefixIcon: Icons.lock,
                              suffixIcon:
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                              obscureText: _obscurePassword,
                              controller: _passwordController,
                              onSuffixIconPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 15),

                            // Chọn loại tài khoản
                            DropdownButtonFormField<String>(
                              value: _role,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'user',
                                  child: Text('Người dùng'),
                                ),
                                DropdownMenuItem(
                                  value: 'doctor',
                                  child: Text('Bác sĩ'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _role = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // Nút Đăng ký bằng email
                            CustomButton(
                              text: 'Đăng ký',
                              onPressed: () async {
                                await viewModel.signUpUser(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  role: _role,
                                  name: _nameController.text,
                                  context: context,
                                );
                                if (viewModel.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(viewModel.error!),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              isLoading: viewModel.isLoading,
                              iconColor: Colors.green,
                            ),

                            const SizedBox(height: 15),

                            // Nút Đăng ký bằng Google
                            CustomButton(
                              text: 'Đăng ký với Google',
                              onPressed: () async {
                                // Hiển thị dialog chọn vai trò
                                final selectedRole =
                                    await _showRoleSelectionDialog();
                                if (selectedRole != null) {
                                  await viewModel.signInWithGoogle(
                                    role: selectedRole,
                                  );
                                  if (viewModel.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(viewModel.error!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              isOutlined: true,
                              icon: Icons.g_mobiledata,
                              iconColor: Colors.red,
                            ),

                            const SizedBox(height: 15),

                            // Nút Đăng ký bằng Facebook
                            CustomButton(
                              text: 'Đăng ký với Facebook',
                              onPressed: () async {
                                final selectedRole =
                                    await _showRoleSelectionDialog();
                                if (selectedRole != null) {
                                  await viewModel.signInWithFacebook(
                                    role: selectedRole,
                                  );
                                  if (viewModel.error?.contains('Google') ??
                                      false) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text(
                                              'Liên kết tài khoản',
                                            ),
                                            content: const Text(
                                              'Email này đã được đăng ký với Google. Bạn có muốn đăng nhập Google để liên kết không?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text(
                                                  'Đăng nhập Google',
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (confirm == true) {
                                      final linked =
                                          await viewModel
                                              .linkPendingCredentialWithGoogle();
                                      if (!mounted) return;
                                      if (linked && viewModel.user != null) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => MainScreen(
                                                  user: viewModel.user!,
                                                ),
                                          ),
                                          (route) => false,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              viewModel.error ??
                                                  'Liên kết tài khoản thất bại',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                              isOutlined: true,
                              icon: Icons.facebook,
                              iconColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Liên kết đăng nhập
                      NavigationLink(
                        text: 'Đã có tài khoản? ',
                        linkText: 'Đăng nhập',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

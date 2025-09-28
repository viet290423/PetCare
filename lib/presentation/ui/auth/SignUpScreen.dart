import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:provider/provider.dart';

import '../doctor/homeScreen/DoctorHomeScreen.dart';
import '../main/MainScreen.dart';
import '../user/homeScreen/UserHomeScreen.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomTextFieldWithIcon.dart';
import '../widget/HeaderSection.dart';
import '../widget/NavigationLink.dart';
import 'LoginScreen.dart';
import '../../../l10n/app_localizations.dart';

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
          title: Text(AppLocalizations.of(context)!.select_role),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.user),
                onTap: () {
                  selectedRole = 'user';
                  Navigator.pop(context, 'user');
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.doctor as String),
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
                  colors: isDark 
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.green.shade100, Colors.white],
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
                      HeaderSection(title: AppLocalizations.of(context)!.signup_title),

                      // Form đăng ký
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Trường Tên
                            CustomTextFieldWithIcon(
                              labelText: AppLocalizations.of(context)!.name,
                              prefixIcon: Icons.person,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 15),

                            // Trường Email
                            CustomTextFieldWithIcon(
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 15),

                            // Trường Mật khẩu
                            CustomTextFieldWithIcon(
                              labelText: AppLocalizations.of(context)!.password,
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
                              items: [
                                DropdownMenuItem(
                                  value: 'user',
                                  child: Text(AppLocalizations.of(context)!.user),
                                ),
                                DropdownMenuItem(
                                  value: 'doctor',
                                  child: Text(AppLocalizations.of(context)!.doctor as String),
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
                              text: AppLocalizations.of(context)!.signup,
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
                              // iconColor: Colors.green,
                            ),

                            const SizedBox(height: 15),

                            // Nút Đăng ký bằng Google
                            CustomButton(
                              text: AppLocalizations.of(context)!.login_with_google,
                              // onPressed: () async {
                              //   // Hiển thị dialog chọn vai trò
                              //   final selectedRole =
                              //       await _showRoleSelectionDialog();
                              //   if (selectedRole != null) {
                              //     await viewModel.signInWithGoogle(
                              //       role: selectedRole,
                              //     );
                              //     if (viewModel.error != null) {
                              //       ScaffoldMessenger.of(context).showSnackBar(
                              //         SnackBar(
                              //           content: Text(viewModel.error!),
                              //           backgroundColor: Colors.red,
                              //         ),
                              //       );
                              //     }
                              //   }
                              // },
                              onPressed: () {},
                              isOutlined: true,
                              icon: Image.asset(
                                'assets/images/gg_icon.png',
                                height: 24,
                                width: 24,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Nút Đăng ký bằng Facebook
                            CustomButton(
                              text: AppLocalizations.of(context)!.login_with_facebook,
                              // onPressed: () async {
                              //   final selectedRole =
                              //       await _showRoleSelectionDialog();
                              //   if (selectedRole != null) {
                              //     await viewModel.signInWithFacebook(
                              //       role: selectedRole,
                              //     );
                              //     if (viewModel.error?.contains('Google') ??
                              //         false) {
                              //       final confirm = await showDialog<bool>(
                              //         context: context,
                              //         builder:
                              //             (_) => AlertDialog(
                              //               title: const Text(
                              //                 'Liên kết tài khoản',
                              //               ),
                              //               content: const Text(
                              //                 'Email này đã được đăng ký với Google. Bạn có muốn đăng nhập Google để liên kết không?',
                              //               ),
                              //               actions: [
                              //                 TextButton(
                              //                   onPressed:
                              //                       () => Navigator.pop(
                              //                         context,
                              //                         false,
                              //                       ),
                              //                   child: const Text('Hủy'),
                              //                 ),
                              //                 TextButton(
                              //                   onPressed:
                              //                       () => Navigator.pop(
                              //                         context,
                              //                         true,
                              //                       ),
                              //                   child: const Text(
                              //                     'Đăng nhập Google',
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //       );
                              //       if (confirm == true) {
                              //         final linked =
                              //             await viewModel
                              //                 .linkPendingCredentialWithGoogle();
                              //         if (!mounted) return;
                              //         if (linked && viewModel.user != null) {
                              //           Navigator.pushAndRemoveUntil(
                              //             context,
                              //             MaterialPageRoute(
                              //               builder:
                              //                   (_) => MainScreen(
                              //                     user: viewModel.user!,
                              //                   ),
                              //             ),
                              //             (route) => false,
                              //           );
                              //         } else {
                              //           ScaffoldMessenger.of(
                              //             context,
                              //           ).showSnackBar(
                              //             SnackBar(
                              //               content: Text(
                              //                 viewModel.error ??
                              //                     'Liên kết tài khoản thất bại',
                              //               ),
                              //             ),
                              //           );
                              //         }
                              //       }
                              //     }
                              //   }
                              // },
                              onPressed: () {},
                              isOutlined: true,
                              icon: Image.asset(
                                'assets/images/fb_logo.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Liên kết đăng nhập
                      NavigationLink(
                        text: AppLocalizations.of(context)!.has_account,
                        linkText: AppLocalizations.of(context)!.login,
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

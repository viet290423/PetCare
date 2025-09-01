import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/auth/SignUpScreen.dart';
import 'package:provider/provider.dart';

import '../main/MainScreen.dart';
import 'AuthViewModel.dart';
import '../doctor/homeScreen/DoctorHomeScreen.dart';
import '../user/homeScreen/UserHomeScreen.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomTextFieldWithIcon.dart';
import '../widget/HeaderSection.dart';
import '../widget/NavigationLink.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
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
                      const HeaderSection(title: 'Đăng nhập'),

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
                            CustomTextFieldWithIcon(
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 15),
                            CustomTextFieldWithIcon(
                              labelText: 'Mật khẩu',
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
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'Đăng nhập',
                              onPressed: () async {
                                await viewModel.signInUser(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  context: context,
                                );
                                if (viewModel.error != null) {
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('Lỗi đăng nhập'),
                                          content: Text(viewModel.error!),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Đóng'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              },
                              isLoading: viewModel.isLoading,
                              iconColor: Colors.green,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Quên mật khẩu?',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Hoặc',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: 'Đăng nhập với Google',
                              icon: Icons.g_mobiledata,
                              iconColor: Colors.red,
                              isOutlined: true,
                              onPressed: () async {
                                final result = await viewModel.signInWithGoogle();
                                if (!mounted) return;

                                result.fold(
                                      (failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(failure.message ?? 'Đăng nhập Google thất bại'),
                                      ),
                                    );
                                  },
                                      (user) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MainScreen(user: user),
                                      ),
                                          (route) => false,
                                    );
                                  },
                                );
                              },
                            ),
                            CustomButton(
                              text: 'Đăng nhập với Facebook',
                              icon: Icons.facebook,
                              iconColor: Colors.blue,
                              isOutlined: true,
                              onPressed: () async {
                                final result = await viewModel.signInWithFacebook();
                                if (!mounted) return;

                                result.fold(
                                      (failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(failure.message ?? 'Đăng nhập Facebook thất bại'),
                                      ),
                                    );
                                  },
                                      (user) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => MainScreen(user: user)),
                                          (route) => false,
                                    );
                                  },
                                );
                              },

                              // onPressed: () async {
                              //   final success = await viewModel
                              //       .signInWithFacebook(role: 'user');
                              //   if (!mounted) return;
                              //   if (success && viewModel.user != null) {
                              //     Navigator.pushAndRemoveUntil(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder:
                              //             (_) =>
                              //                 MainScreen(user: viewModel.user!),
                              //       ),
                              //       (route) => false,
                              //     );
                              //   } else if (viewModel.error?.contains(
                              //         'Google',
                              //       ) ??
                              //       false) {
                              //     final confirm = await showDialog<bool>(
                              //       context: context,
                              //       builder:
                              //           (_) => AlertDialog(
                              //             title: const Text(
                              //               'Liên kết tài khoản',
                              //             ),
                              //             content: const Text(
                              //               'Email này đã được đăng ký với Google. Bạn có muốn đăng nhập Google để liên kết không?',
                              //             ),
                              //             actions: [
                              //               TextButton(
                              //                 onPressed:
                              //                     () => Navigator.pop(
                              //                       context,
                              //                       false,
                              //                     ),
                              //                 child: const Text('Hủy'),
                              //               ),
                              //               TextButton(
                              //                 onPressed:
                              //                     () => Navigator.pop(
                              //                       context,
                              //                       true,
                              //                     ),
                              //                 child: const Text(
                              //                   'Đăng nhập Google',
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //     );
                              //     if (confirm == true) {
                              //       final linked =
                              //           await viewModel
                              //               .linkPendingCredentialWithGoogle();
                              //       if (!mounted) return;
                              //       if (linked && viewModel.user != null) {
                              //         Navigator.pushAndRemoveUntil(
                              //           context,
                              //           MaterialPageRoute(
                              //             builder:
                              //                 (_) => MainScreen(
                              //                   user: viewModel.user!,
                              //                 ),
                              //           ),
                              //           (route) => false,
                              //         );
                              //       } else {
                              //         ScaffoldMessenger.of(
                              //           context,
                              //         ).showSnackBar(
                              //           SnackBar(
                              //             content: Text(
                              //               viewModel.error ??
                              //                   'Liên kết tài khoản thất bại',
                              //             ),
                              //           ),
                              //         );
                              //       }
                              //     }
                              //   } else {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         content: Text(
                              //           viewModel.error ??
                              //               'Đăng nhập Facebook thất bại',
                              //         ),
                              //       ),
                              //     );
                              //   }
                              // },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      NavigationLink(
                        text: 'Bạn chưa có tài khoản? ',
                        linkText: 'Đăng ký',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
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

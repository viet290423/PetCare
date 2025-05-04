import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/AuthProvider.dart';
import '../auth/AuthViewModel.dart';
import '../auth/LoginScreen.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ - Bác sĩ'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.signOutUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Chào mừng đến với PetCare (Bác sĩ)!\nBạn có thể xem lịch hẹn, tư vấn cho người dùng.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

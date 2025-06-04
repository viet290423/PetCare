import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cộng đồng thú cưng'),
        backgroundColor: Colors.orange.shade400,
        leading: const Icon(Icons.groups, color: Colors.white),
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 80, color: Colors.orange.shade200),
            const SizedBox(height: 20),
            const Text(
              'Cộng đồng yêu thú cưng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Chia sẻ kinh nghiệm, hỏi đáp, kết nối với bác sĩ và chủ nuôi khác!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

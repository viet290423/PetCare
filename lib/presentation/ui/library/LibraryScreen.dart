import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện bệnh & kiến thức'),
        backgroundColor: Colors.green.shade400,
        leading: const Icon(Icons.menu_book, color: Colors.white),
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.green.shade200),
            const SizedBox(height: 20),
            const Text(
              'Thư viện bệnh & kiến thức thú cưng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tra cứu thông tin bệnh, cách chăm sóc, dinh dưỡng, phòng bệnh... tại đây!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

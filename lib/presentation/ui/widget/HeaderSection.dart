import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String title;

  const HeaderSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Image.asset('assets/images/logo.png', height: 200),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

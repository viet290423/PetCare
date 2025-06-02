import 'package:flutter/material.dart';

class ServiceScreen extends StatefulWidget{
  const ServiceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ServiceScreen();
}

class _ServiceScreen extends State<ServiceScreen>{
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dịch vụ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );
  }
}
import 'package:flutter/material.dart';

class CustomMyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Icon? suffixIcon;
  final String? suffixText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final GestureTapCallback? onTap;
  final TextInputType? keyboardType;

  const CustomMyTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixText,
    required this.controller,
    this.validator,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
      ),
      validator: validator,
      onTap: onTap,
      keyboardType: keyboardType,
    );
  }
}

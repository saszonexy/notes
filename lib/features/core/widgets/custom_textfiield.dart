import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType
      keyboardType; 
  final IconData? icon; 

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon) : null, // ⬅️ tambah icon kalau ada
      ),
    );
  }
}

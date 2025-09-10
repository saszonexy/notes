import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tailwind_colors/tailwind_colors.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _register() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: TWColors.blue.shade600,
            content: Text("Registrasi berhasil: ${result['message'] ?? ''}"),
          ),
        );

        Navigator.pushReplacementNamed(context, "/login");
      } else {
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? "Registrasi gagal");
      }
    } catch (e) {
      _showError("Terjadi error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TWColors.red.shade600,
        content: Text(message),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {bool isPassword = false}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
      filled: true,
      fillColor: TWColors.gray.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TWColors.gray.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create an account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: TWColors.gray.shade800,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                child: Text(
                  "Already have an account? Log in",
                  style: TextStyle(
                    color: TWColors.blue.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Full Name"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: _inputDecoration("Email"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration("Password", isPassword: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TWColors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

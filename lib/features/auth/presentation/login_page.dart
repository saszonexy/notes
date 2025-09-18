import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_button.dart';
import '../logic/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                _header(),

                const SizedBox(height: 32),

                // Form
                _form(context),

                const SizedBox(height: 24),

                // Register link
                _registerLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD2B48C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4E4BC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B4513).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 40,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Welcome Back to Notebook",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: "Georgia",
              color: Color(0xFF8B4513),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Login to your notebook",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8B4513).withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE6D3B7).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          const Text(
            "Email Address",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B4513),
              fontFamily: "Georgia",
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailCtrl,
            style: const TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
            decoration: _inputDecoration(
              hint: "Enter your email",
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Password
          const Text(
            "Password",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B4513),
              fontFamily: "Georgia",
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passCtrl,
            obscureText: _obscurePass,
            style: const TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
            decoration: _inputDecoration(
              hint: "Enter your password",
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF8B4513),
                ),
                onPressed: () {
                  setState(() => _obscurePass = !_obscurePass);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Login Button
          CustomButton(
            text: "Login to Notebook",
            onPressed: () {
              context.read<AuthCubit>().login(
                    emailCtrl.text.trim(),
                    passCtrl.text.trim(),
                  );
              Navigator.pushReplacementNamed(context, '/notes');
            },
          ),
        ],
      ),
    );
  }

  Widget _registerLink(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E4BC).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2B48C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don’t have a notebook? ",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8B4513).withOpacity(0.8),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: const Text(
              "Create one",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF8B4513),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF8B4513).withOpacity(0.5)),
      filled: true,
      fillColor: const Color(0xFFFAF7F0),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4E4BC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF8B4513), size: 20),
      ),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFD2B48C).withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFD2B48C).withOpacity(0.5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

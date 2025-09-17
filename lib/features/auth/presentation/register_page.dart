import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../logic/auth_cubit.dart';

class RegisterPage extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: emailCtrl, label: "Email"),
            const SizedBox(height: 12),
            CustomTextField(
              controller: passCtrl,
              label: "Password",
              obscure: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Register",
              onPressed: () {
                context.read<AuthCubit>().register(
                      emailCtrl.text.trim(),
                      passCtrl.text.trim(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

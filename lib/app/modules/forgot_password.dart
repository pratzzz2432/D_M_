import 'package:flutter/material.dart';
import 'package:d_m/app/modules/auth.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();

  ForgotPasswordPage({super.key});

  void _resetPassword() {
    _authService.resetPassword(emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            ElevatedButton(onPressed: _resetPassword, child: const Text('Reset Password'))
          ],
        ),
      ),
    );
  }
}

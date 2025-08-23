import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/sanitize.dart';

class VerifyResetScreen extends StatefulWidget {
  const VerifyResetScreen({super.key});

  @override
  State<VerifyResetScreen> createState() => _VerifyResetScreenState();
}

class _VerifyResetScreenState extends State<VerifyResetScreen> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final backendUrl = "https://fyp-25-s2-08.onrender.com";
  final sanitize = Sanitize();

  bool isSubmitting = false;
  String? message;

  Future<void> resetPassword(String email) async {
    setState(() {
      isSubmitting = true;
      message = null;
    });

    final passwordResult = sanitize.isValidPassword(passwordController.text);
    if (!passwordResult.valid) {
      setState(() {
        isSubmitting = false;
        message = passwordResult.message;
      });
      return;
    }

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      setState(() {
        isSubmitting = false;
        message = "Passwords do not match.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/verify-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otpController.text.trim(),
          'newPassword': passwordResult.value,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() => message = data['message'] ?? 'Reset failed');
      }
    } catch (e) {
      setState(() => message = 'Server error: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Resetting password for $email'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Repeat Password'),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting ? null : () => resetPassword(email),
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}

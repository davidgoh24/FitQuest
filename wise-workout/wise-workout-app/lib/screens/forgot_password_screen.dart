import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final backendUrl = "https://fyp-25-s2-08.onrender.com";
  bool isSubmitting = false;
  String? message;

  Future<void> sendResetOtp() async {
    setState(() {
      isSubmitting = true;
      message = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/verify-reset', arguments: emailController.text.trim());
      } else {
        setState(() => message = data['message'] ?? 'forgot_otp_error'.tr());
      }
    } catch (e) {
      setState(() => message = 'forgot_otp_server_error'.tr(args: [e.toString()]));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("forgot_title".tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'forgot_email_label'.tr()),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting ? null : sendResetOtp,
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : Text("forgot_send_button".tr()),
            ),
          ],
        ),
      ),
    );
  }
}

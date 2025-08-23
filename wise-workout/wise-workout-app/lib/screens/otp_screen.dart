import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'questionnaires/questionnaire_screen.dart';
import 'questionnaires/questionnaire_screen_start.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  final secureStorage = const FlutterSecureStorage();
  final backendUrl = "https://fyp-25-s2-08.onrender.com";

  bool isSubmitting = false;
  String? error;

  Future<void> verifyOtp() async {
    setState(() {
      isSubmitting = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/verify-otp-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': otpController.text.trim(),
        }),
      );

      final cookie = response.headers['set-cookie'];
      if (response.statusCode == 201 && cookie != null) {
        final jwt = cookie.split(';').first.split('=').last;
        await secureStorage.write(key: 'jwt_cookie', value: jwt);
        await navigateAfterVerification(jwt);
      } else {
        final data = jsonDecode(response.body);
        setState(() => error = data['message'] ?? 'otp_error_invalid'.tr());
      }
    } catch (e) {
      setState(() => error = 'otp_error_server'.tr(args: [e.toString()]));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> navigateAfterVerification(String jwt) async {
    final hasPreferences = await checkPreferences(jwt);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasPreferences) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SplashAndOnboardingWrapper(),
          ),
        );
      }
    });
  }

  Future<bool> checkPreferences(String jwt) async {
    final res = await http.get(
      Uri.parse('$backendUrl/questionnaire/check'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['hasPreferences'] as bool;
    } else {
      setState(() => error = 'otp_error_check_preferences'.tr());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('otp_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('otp_subtitle'.tr(args: [widget.email])),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'otp_label'.tr()),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting ? null : verifyOtp,
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : Text('otp_button_verify'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

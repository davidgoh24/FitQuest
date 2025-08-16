import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../widgets/google_login_button.dart';
import '../widgets/apple_login_button.dart';
import '../widgets/facebook_login_button.dart';
import '../utils/sanitize.dart';
import 'questionnaires/questionnaire_screen_start.dart';
import 'package:easy_localization/easy_localization.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final secureStorage = FlutterSecureStorage();
  final authService = AuthService();
  final sanitize = Sanitize();
  final backendUrl = "https://fyp-25-s2-08.onrender.com";
  bool _obscurePassword = true;

  Future<void> loginWithEmail() async {
    final emailResult = sanitize.isValidEmail(emailController.text);
    final passwordResult = sanitize.isValidPassword(passwordController.text);
    if (!emailResult.valid) {
      showError(emailResult.message ?? 'login_invalid_email'.tr());
      return;
    }
    if (!passwordResult.valid) {
      showError(passwordResult.message ?? 'login_invalid_password'.tr());
      return;
    }
    final email = emailResult.value;
    final password = passwordResult.value;
    final response = await http.post(
      Uri.parse('$backendUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final cookie = response.headers['set-cookie'];
    if (response.statusCode == 200 && cookie != null) {
      final jwt = cookie.split(';').first.split('=').last;
      await secureStorage.write(key: 'jwt_cookie', value: jwt);
      showSuccess('login_success'.tr());
      await navigateAfterLogin(jwt);
    } else {
      String msg = 'login_invalid_credentials'.tr();
      try {
        msg = jsonDecode(response.body)['message'] ?? msg;
      } catch (_) {}
      showError(msg);
    }
  }

  Future<void> loginWithGoogle() async {
    final googleData = await authService.signInWithGoogle();
    if (googleData == null) {
      showError('login_google_cancelled'.tr());
      return;
    }
    final response = await http.post(
      Uri.parse('$backendUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': googleData['email'],
        'firstName': googleData['firstName'],
        'lastName': googleData['lastName'],
      }),
    );
    print('Google login status: ${response.statusCode}');
    print('Google login response: ${response.body}');
    final cookie = response.headers['set-cookie'];
    if (response.statusCode == 200 && cookie != null) {
      final jwt = cookie.split(';').first.split('=').last;
      await secureStorage.write(key: 'jwt_cookie', value: jwt);
      showSuccess('login_google_success'.tr());
      await navigateAfterLogin(jwt);
    } else {
      String msg = 'login_google_failed'.tr();
      try {
        msg = jsonDecode(response.body)['message'] ?? msg;
      } catch (_) {}
      showError(msg);
    }
  }

  Future<void> loginWithFacebook() async {
    final fbData = await authService.signInWithFacebook();
    if (fbData == null) {
      showError('login_facebook_cancelled'.tr());
      return;
    }
    final response = await http.post(
      Uri.parse('$backendUrl/auth/facebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': fbData['email'],
        'firstName': fbData['firstName'],
        'lastName': fbData['lastName'],
      }),
    );
    print('Facebook login status: ${response.statusCode}');
    print('Facebook login response: ${response.body}');
    final cookie = response.headers['set-cookie'];
    if (response.statusCode == 200 && cookie != null) {
      final jwt = cookie.split(';').first.split('=').last;
      await secureStorage.write(key: 'jwt_cookie', value: jwt);
      showSuccess('login_facebook_success'.tr());
      await navigateAfterLogin(jwt);
    } else {
      String msg = 'login_facebook_failed'.tr();
      try {
        msg = jsonDecode(response.body)['message'] ?? msg;
      } catch (_) {}
      showError(msg);
    }
  }

  Future<void> navigateAfterLogin(String jwt) async {
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
      showError('login_check_preferences_failed'.tr());
      return false;
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isAndroid = Platform.isAndroid;
    final bool isIOS = Platform.isIOS;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icons/fitquest-icon.png',
                  height: 150,
                ),
                const SizedBox(height: 32),
                Text(
                  "login_email_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'login_email_hint'.tr(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "login_password_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'login_password_hint'.tr(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: loginWithEmail,
                  child: Text(
                    'login_button'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isAndroid) ...[
                  GoogleLoginButton(onPressed: loginWithGoogle),
                  const SizedBox(height: 12),
                ],
                if (isIOS) ...[
                  const AppleLoginButton(),
                  const SizedBox(height: 12),
                ],
                FacebookLoginButton(onPressed: loginWithFacebook),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      'login_forgot_password'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'login_create_account'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
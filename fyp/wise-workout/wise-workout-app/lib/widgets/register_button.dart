import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/sanitize.dart';
import '../screens/otp_screen.dart';
import 'package:flutter/material.dart';

final _backendUrl = 'https://fyp-25-s2-08.onrender.com';

Future<String?> registerUser(
  BuildContext context,
  String email,
  String username,
  String password,
  String firstName,
  String lastName,
) async {
  final sanitize = Sanitize();
  final usernameResult = sanitize.isValidUsername(username);
  final emailResult = sanitize.isValidEmail(email);
  final passwordResult = sanitize.isValidPassword(password);
  final firstNameResult = sanitize.isValidFirstName(firstName);
  final lastNameResult = sanitize.isValidLastName(lastName);

  if (!emailResult.valid || !passwordResult.valid || !usernameResult.valid || !firstNameResult.valid || !lastNameResult.valid) {
    return 'Invalid input: ${emailResult.message ?? ''} ${passwordResult.message ?? ''} ${usernameResult.message ?? ''} ${firstNameResult.message ?? ''} ${lastNameResult.message ?? ''}';
  }

  try {
    final response = await http.post(
      Uri.parse('$_backendUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailResult.value,
        'username': usernameResult.value,
        'password': passwordResult.value,
        'firstName': firstNameResult.value,
        'lastName': lastNameResult.value,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: emailResult.value),
        ),
      );
      return null;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'Registration failed';
    }
  } catch (e) {
    return 'Server error: $e';
  }
}

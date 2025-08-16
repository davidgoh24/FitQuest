import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileEditService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  Future<bool> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? dob,
    String? email,
  }) async {
    final cookie = await storage.read(key: 'jwt_cookie');
    if (cookie == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/user/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$cookie',
      },
      body: jsonEncode({
        if (username != null) 'username': username,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (dob != null) 'dob': dob,
        if (email != null) 'email': email,
      }),
    );

    return response.statusCode == 200;
  }
}

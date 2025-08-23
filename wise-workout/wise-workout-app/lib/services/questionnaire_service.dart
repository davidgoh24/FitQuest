import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QuestionnaireService {
  static final String backendUrl = 'https://fyp-25-s2-08.onrender.com';
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<bool> submitPreferences(Map<String, dynamic> responses) async {
    final jwt = await storage.read(key: 'jwt_cookie');
    if (jwt == null) {
      print('JWT not found in secure storage');
      return false;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/questionnaire/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode(responses),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response.statusCode == 200;
  }

  static Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    final jwt = await storage.read(key: 'jwt_cookie');
    if (jwt == null) {
      print('JWT not found in secure storage');
      return false;
    }

    final response = await http.put(
      Uri.parse('$backendUrl/questionnaire/update'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode(prefs),
    );

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

    return response.statusCode == 200;
  }

}

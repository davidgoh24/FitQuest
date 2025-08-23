import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FeedbackService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';

  Future<void> submitFeedback({
    required int rating,
    String? message,
    List<String>? likedFeatures,
    List<String>? problems,
  }) async {
    String? jwt = await storage.read(key: 'jwt_cookie');
    final response = await http.post(
      Uri.parse('$baseUrl/feedback/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({
        'rating': rating,
        'message': message,
        'liked_features': likedFeatures ?? [],
        'problems': problems ?? [],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit feedback');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPublishedFeedback() async {
    String? jwt = await storage.read(key: 'jwt_cookie');
    final response = await http.get(
      Uri.parse('$baseUrl/feedback/published'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(
        'Failed to load feedback (status: ${response.statusCode}, body: ${response.body})',
      );
    }
  }
}

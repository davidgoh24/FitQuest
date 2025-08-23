import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkoutCategory {
  final String categoryId;
  final String categoryName;
  final String categoryKey;
  final String categoryDescription;
  final String imageUrl;

  WorkoutCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryKey,
    required this.categoryDescription,
  }) : imageUrl = _generateImageUrl(categoryKey);

  static String _generateImageUrl(String categoryKey) {
    return 'assets/workoutCategory/${categoryKey.replaceAll(' ', '_').toLowerCase()}.jpg';
  }

  factory WorkoutCategory.fromJson(Map<String, dynamic> json) {
    return WorkoutCategory(
      categoryId: json['categoryId'].toString(),
      categoryName: json['categoryName'],
      categoryKey: json['categoryKey'],
      categoryDescription: json['categoryDescription'],
    );
  }
}

class WorkoutCategoryService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    return await _storage.read(key: 'jwt_cookie');
  }

  Future<List<WorkoutCategory>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workout-categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch workout categories');
      }

      final data = jsonDecode(response.body);
      return List<WorkoutCategory>.from(data.map((item) => WorkoutCategory.fromJson(item)));
    } catch (e, stackTrace) {
      print('❌ Error fetching categories: $e');
      print('🧱 Stack trace:\n$stackTrace');
      rethrow; // Optional: Rethrow to show error in UI
    }
  }


  Future<WorkoutCategory?> getCategoryByKey(String categoryKey) async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/workout-categories/$categoryKey'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch category');
    }

    final item = jsonDecode(response.body);
    return WorkoutCategory.fromJson(item);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LeaderboardService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    return await _storage.read(key: 'jwt_cookie');
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard({String type = 'levels', int limit = 20}) async {
    final jwt = await _getJwtCookie();
    final uri = Uri.parse('$baseUrl/user/leaderboard?type=$type&limit=$limit');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load leaderboard');
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }
}

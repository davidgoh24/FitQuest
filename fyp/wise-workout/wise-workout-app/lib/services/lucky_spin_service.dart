import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LuckySpinService {
  final secureStorage = const FlutterSecureStorage();
  final baseUrl = 'https://fyp-25-s2-08.onrender.com';

  Future<List<String>> fetchPrizes() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/prizes'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['prizes'] as List)
        .map((p) => '     ' + p['label'].toString())
        .toList();
    } else {
      throw Exception('Failed to load prizes');
    }
  }

  Future<Map<String, dynamic>> checkSpinStatus() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/lucky/spin/status'),
      headers: {'Cookie': 'session=$jwt', 'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load spin status');
    }
  }

  Future<Map<String, dynamic>> spin({bool useTokens = false}) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/lucky/spin${useTokens ? '?force=true' : ''}'),
      headers: {'Cookie': 'session=$jwt', 'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 403) {
      throw Exception('Already spun today or not enough tokens');
    } else {
      throw Exception('Failed to spin');
    }
  }
}

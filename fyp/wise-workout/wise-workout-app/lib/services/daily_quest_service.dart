import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DailyQuestService {
  final String backendUrl = 'https://fyp-25-s2-08.onrender.com';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchDailyQuests() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.get(
      Uri.parse('$backendUrl/user/daily-quests'),
      headers: {'Cookie': 'session=$jwt'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to fetch daily quests');
    }
  }

  Future<void> claimQuest(String questCode) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.post(
      Uri.parse('$backendUrl/user/claim-quest'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'questCode': questCode}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to claim quest');
    }
  }

  Future<void> claimAllQuests() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.post(
      Uri.parse('$backendUrl/user/claim-all-quests'),
      headers: {
        'Cookie': 'session=$jwt',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to claim all quests');
    }
  }
}

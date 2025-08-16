import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String backendUrl = 'https://fyp-25-s2-08.onrender.com';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> checkAuthStatus() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) return false;

    try {
      final res = await http.get(
        Uri.parse('$backendUrl/auth/me'),
        headers: {'Cookie': 'session=$jwt'},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurrentProfile() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.get(
      Uri.parse('$backendUrl/user/current-profile'),
      headers: {'Cookie': 'session=$jwt'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> setAvatar(int avatarId) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.post(
      Uri.parse('$backendUrl/user/set-avatar'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'avatarId': avatarId}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to set avatar');
    }
  }

  Future<void> setBackground(int backgroundId) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.post(
      Uri.parse('$backendUrl/user/set-background'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'backgroundId': backgroundId}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to set background');
    }
  }

  Future<Map<String, dynamic>> getCurrentBackground() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');
    final res = await http.get(
      Uri.parse('$backendUrl/user/current-background'),
      headers: {'Cookie': 'session=$jwt'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load current background');
    }
  }

  Future<Map<String, dynamic>> buyPremiumWithTokens(String plan) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) return {'success': false, 'message': 'Not logged in'};
    final res = await http.post(
      Uri.parse('$backendUrl/user/buy-premium'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({
        'type': 'premium_token',
        'plan': plan,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {'success': true, 'message': data['message'] ?? 'Success'};
    } else {
      String error = 'Purchase failed';
      try {
        error = jsonDecode(res.body)['message'] ?? error;
      } catch (_) {}
      return {'success': false, 'message': error};
    }
  }

  Future<Map<String, dynamic>> buyPremiumWithMoney(String plan, String paymentId) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) return {'success': false, 'message': 'Not logged in'};
    final res = await http.post(
      Uri.parse('$backendUrl/user/buy-premium'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({
        'type': 'premium_money',
        'plan': plan,
        'paymentId': paymentId,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {'success': true, 'message': data['message'] ?? 'Success'};
    } else {
      String error = 'Purchase failed';
      try {
        error = jsonDecode(res.body)['message'] ?? error;
      } catch (_) {}
      return {'success': false, 'message': error};
    }
  }

  Future<int> getDailyXP(String date) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');

    final res = await http.get(
      Uri.parse('$backendUrl/user/daily-xp?date=$date'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['xp'] ?? 0;
    } else {
      throw Exception('Failed to load daily XP');
    }
  }
  Future<String> getLanguage() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');

    final res = await http.get(
      Uri.parse('$backendUrl/user/language'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['language'] ?? 'en';
    } else {
      throw Exception('Failed to load language');
    }
  }

  Future<void> setLanguage(String language) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('JWT not found in secure storage');

    final res = await http.put(
      Uri.parse('$backendUrl/user/language'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'language': language}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update language');
    }
  }
}

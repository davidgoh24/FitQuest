import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChallengeService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    return await _storage.read(key: 'jwt_cookie');
  }

  Future<List<Map<String, dynamic>>> getAllChallenges() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/list'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load challenges');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<void> sendChallenge({
    required int receiverId,
    required String title,
    required int customValue,
    int? customDurationValue,
    String? customDurationUnit,
  }) async {
    final jwt = await _getJwtCookie();
    final Map<String, dynamic> body = {
      'receiverId': receiverId,
      'title': title,
      'customValue': customValue,
      'customDurationValue': customDurationValue,
      'customDurationUnit': customDurationUnit,
    };
    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/challenges/send'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Map<String, dynamic>>> getInvitations() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/invitations'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load invitations');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> getAcceptedChallenges() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/accepted'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load accepted challenges');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<void> acceptChallenge(int challengeId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/challenges/$challengeId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> rejectChallenge(int challengeId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/challenges/$challengeId/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Map<String, dynamic>>> getFriendsToChallenge(String title) async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/challenges/friends-to-challenge?title=${Uri.encodeComponent(title)}'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load friends to challenge');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final jwt = await _getJwtCookie();
    final r = await http.get(
      Uri.parse('$baseUrl/challenges/leaderboard'),
      headers: {'Content-Type': 'application/json', 'Cookie': 'session=$jwt'},
    );
    if (r.statusCode != 200) {
      throw Exception('Failed to load leaderboard');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(r.body));
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FriendService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    return await _storage.read(key: 'jwt_cookie');
  }

  Future<void> sendRequest(String friendId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/friends/send'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'friendId': friendId}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
  Future<List<dynamic>> searchUsers(String query) async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/friends/search?query=${Uri.encodeComponent(query)}'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to search users');
    }
    return jsonDecode(response.body);
  }

  Future<void> acceptRequest(String friendId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/friends/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'friendId': friendId}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> rejectRequest(String friendId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/friends/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({'friendId': friendId}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/friends/list'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/friends/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getSentRequests() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/friends/sent'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPremiumFriends() async {
    final jwt = await _getJwtCookie();  // get jwt token

    final response = await http.get(
      Uri.parse('$baseUrl/friends/premium'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load premium friends');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

}

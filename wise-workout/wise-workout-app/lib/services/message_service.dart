import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MessageService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    return await _storage.read(key: 'jwt_cookie');
  }

  Future<void> sendMessage(int receiverId, String content) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'content': content,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> getConversation(int otherUserId) async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversation/$otherUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
    return jsonDecode(response.body); 
  }
  Future<List<Map<String, dynamic>>> getUnreadCounts() async {
    final jwt = await _getJwtCookie();
    final response = await http.get(
      Uri.parse('$baseUrl/messages/unread-counts'),
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


  Future<void> markAsRead(int friendId) async {
    final jwt = await _getJwtCookie();
    final response = await http.post(
      Uri.parse('$baseUrl/messages/mark-as-read'),
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

}

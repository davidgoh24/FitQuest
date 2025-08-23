import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class ReminderService {
  final String backendUrl = 'https://fyp-25-s2-08.onrender.com';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> fetchReminder() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) return null;

    final res = await http.get(
      Uri.parse('$backendUrl/reminders'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      if (res.body.isEmpty) return null;
      final data = jsonDecode(res.body);
      if (data == null || data.isEmpty) return null;
      return data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch reminder: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> syncAndSchedule() async {
    final reminder = await fetchReminder();
    if (reminder == null) return;

    final id = reminder['id'] as int;
    final title = reminder['title'] as String;
    final message = reminder['message'] as String;

    final timeParts = (reminder['time'] as String).split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    final daysOfWeek = (reminder['days_of_week'] as String)
        .split(',')
        .map((d) => int.parse(d.trim()))
        .toList();

    await NotificationService.scheduleReminder(
      id: id,
      title: title,
      body: message,
      time: timeOfDay,
      daysOfWeek: daysOfWeek,
    );
  }

  Future<Map<String, dynamic>> setReminder({
    required String title,
    required String message,
    required TimeOfDay time,
    required List<int> daysOfWeek,
  }) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('Not authenticated');

    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

    final res = await http.post(
      Uri.parse('$backendUrl/reminders'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
      body: jsonEncode({
        'title': title,
        'message': message,
        'time': timeStr,
        'daysOfWeek': daysOfWeek.join(','),
      }),
    );

    if (res.statusCode == 201) {
      final reminder = jsonDecode(res.body);

      await NotificationService.scheduleReminder(
        id: reminder['id'],
        title: title,
        body: message,
        time: time,
        daysOfWeek: daysOfWeek,
      );

      return reminder;
    } else {
      throw Exception('Failed to save reminder: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> clearReminder() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    if (jwt == null) throw Exception('Not authenticated');

    final res = await http.delete(
      Uri.parse('$backendUrl/reminders'),
      headers: {'Cookie': 'session=$jwt'},
    );

    if (res.statusCode == 200) {
      await NotificationService.cancelAllReminders();
    } else {
      throw Exception('Failed to clear reminder: ${res.statusCode} ${res.body}');
    }
  }
}

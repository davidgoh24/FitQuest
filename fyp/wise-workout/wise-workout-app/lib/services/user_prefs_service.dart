import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsService {
  static const _kWorkoutStartHour = 'workout_start_hour';
  static const _kWorkoutStartMinute = 'workout_start_minute';

  static Future<void> setWorkoutStartTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWorkoutStartHour, hour);
    await prefs.setInt(_kWorkoutStartMinute, minute);
  }

  static Future<Map<String, int>> getWorkoutStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_kWorkoutStartHour) ?? 7;
    final minute = prefs.getInt(_kWorkoutStartMinute) ?? 0;
    return {
      'hour': hour,
      'minute': minute,
    };
  }
}

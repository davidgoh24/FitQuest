import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/model/workout_model.dart';

class WorkoutService {
  final String baseUrl = 'https://fyp-25-s2-08.onrender.com';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getJwtCookie() async {
    final cookie = await _storage.read(key: 'jwt_cookie');
    return cookie;
  }

  Future<List<Workout>> fetchAllWorkouts() async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workouts');
    final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session=$jwt',
          },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch workouts');
    }

    final data = jsonDecode(response.body);
    return List<Workout>.from(data.map((item) => Workout.fromJson(item)));
  }

  Future<List<Workout>> fetchWorkoutsByCategory(String categoryKey) async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workouts/category/$categoryKey');
    final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session=$jwt',
          },
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch category workouts');
    }

    final data = jsonDecode(response.body);
    return List<Workout>.from(data.map((item) => Workout.fromJson(item)));
  }

  Future<Workout> fetchWorkoutById(int workoutId) async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workouts/$workoutId');
    final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session=$jwt',
          },
        );
    if (response.statusCode != 200) {
          throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch workout');
        }

    final item = jsonDecode(response.body);
    return Workout.fromJson(item);
  }

  Future<List<double>> fetchHourlyCaloriesForDate(DateTime date, {String? devUserId}) async {
    final jwt = await _getJwtCookie();

    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');

    final qp = devUserId == null ? 'date=$y-$m-$d' : 'date=$y-$m-$d&userId=$devUserId';
    final url = Uri.parse('$baseUrl/workout-sessions/sessions/hourly-calories?$qp');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (jwt != null) 'Cookie': 'session=$jwt',
    };

    final res = await http.get(url, headers: headers);

    print('[HourlyCalories] GET $url -> ${res.statusCode}');
    if (res.statusCode != 200) {
      print('[HourlyCalories] Body: ${res.body}');
      return List<double>.filled(24, 0.0, growable: false);
    }

    final body = json.decode(res.body);

    if (body is Map && body['hourly'] is List) {
      final List<dynamic> raw = body['hourly'] as List<dynamic>;
      final hourly = raw.map((e) => (e is num) ? e.toDouble() : 0.0).toList(growable: false);
      if (hourly.length < 24) {
        return List<double>.from([...hourly, ...List<double>.filled(24 - hourly.length, 0.0)], growable: false);
      } else if (hourly.length > 24) {
        return hourly.sublist(0, 24);
      }
      return hourly;
    }

    if (body is Map && body['hourly'] is Map) {
      final map = Map<String, dynamic>.from(body['hourly'] as Map);
      final hourly = List<double>.generate(24, (h) {
        final keyA = h.toString().padLeft(2, '0');
        final keyB = h.toString();
        final v = map.containsKey(keyA) ? map[keyA] : (map.containsKey(keyB) ? map[keyB] : 0);
        return (v is num) ? v.toDouble() : 0.0;
      }, growable: false);
      return hourly;
    }

    return List<double>.filled(24, 0.0, growable: false);
  }




  Future<void> saveWorkoutSession({
    int? workoutId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    double? caloriesBurned,
    String? notes,
    List<Map<String, dynamic>> exercises = const [],
  }) async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workout-sessions/sessions');
    
    final requestBody = {
      'workoutId': workoutId,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'exercises': exercises,
    };
    final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session=$jwt',
          },
          body: jsonEncode(requestBody),
        );
    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to save workout session');
    }
  }

  Future<List<dynamic>> fetchUserWorkoutSessions() async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workout-sessions/sessions');
    final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session=$jwt',
          },
        );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch workout sessions');
    }

    final data = jsonDecode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> fetchTodayCaloriesSummary() async {
    final jwt = await _getJwtCookie();
    final url = Uri.parse('$baseUrl/workout-sessions/sessions/today/summary');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch today calories summary');
    }

    final data = jsonDecode(response.body);
    return {
      'totalCalories': data['totalCalories'] ?? 0,
      'firstStartTime': data['firstStartTime'],
    };
  }


  String _fmtDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  List<DateTime> _buildInclusiveDateRange(DateTime from, DateTime to) {
    DateTime a = DateTime(from.year, from.month, from.day);
    DateTime b = DateTime(to.year, to.month, to.day);
    if (a.isAfter(b)) {
      final tmp = a;
      a = b;
      b = tmp;
    }
    final days = <DateTime>[];
    for (var d = a; !d.isAfter(b); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }
  Future<String> fetchSessionIntensity(int sessionId) async {
    final jwt = await _storage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/workout-sessions/sessions/$sessionId/intensity'),
      headers: {'Cookie': 'session=$jwt'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['intensity'] ?? 'Unknown';
    } else {
      throw Exception('Failed to fetch session intensity');
    }
  }


// --- ADD: Core fetchers ------------------------------------------------------

  Future<Map<String, int>> fetchDailyCaloriesSummaryMap({
    required DateTime from,
    required DateTime to,
  }) async {
    final jwt = await _getJwtCookie();
    final params = "from=${_fmtDate(from)}&to=${_fmtDate(to)}";
    final url = Uri.parse('$baseUrl/workout-sessions/sessions/summary?$params');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session=$jwt',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to fetch daily calories summary');
    }

    final jsonBody = jsonDecode(response.body);
    final List days = (jsonBody['days'] ?? []) as List;

    // API returns only days that have sessions; convert to map.
    final result = <String, int>{};
    for (final item in days) {
      final dateStr = item['date']?.toString();
      final total = item['totalCalories'];
      if (dateStr == null) continue;
      final val = (total is num) ? total.round() : int.tryParse('$total') ?? 0;
      result[dateStr] = val;
    }
    return result;
  }

  Future<Map<String, dynamic>> fetchDailyCaloriesSeries({
    required DateTime from,
    required DateTime to,
  }) async {
    final map = await fetchDailyCaloriesSummaryMap(from: from, to: to);

    final range = _buildInclusiveDateRange(from, to);
    final labels = <String>[];
    final values = <int>[];

    for (final d in range) {
      final key = _fmtDate(d);
      labels.add(key);
      values.add(map[key] ?? 0);
    }

    return {
      'labels': labels,
      'values': values,
    };
  }
}

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../screens/model/workout_day_model.dart';
import '../screens/model/exercise_model.dart';

class AIFitnessPlanService {
  final secureStorage = const FlutterSecureStorage();
  final baseUrl = 'https://fyp-25-s2-08.onrender.com';

  /// Calls your AI route to generate a plan (does NOT save it).
  /// Same behavior as before.
  Future<Map<String, dynamic>> fetchPlanFromDB() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.post(
      Uri.parse('$baseUrl/ai/fitness-plan'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch AI fitness plan');
    }

    final data = jsonDecode(res.body);

    // NEW server shape
    if (data is Map && data['plan'] != null) {
      return {
        'plan': List<dynamic>.from(data['plan']),
        'preferences': data['preferences'],
        if (data['estimation_text'] != null)
          'estimation_text': data['estimation_text'].toString(),
      };
    }

    // Fallback to old OpenRouter passthrough (if ever needed)
    final aiText = data['ai']['choices'][0]['message']['content'];
    final parsed = jsonDecode(aiText);

    if (parsed is Map && parsed['plan'] != null) {
      return {
        'plan': List<dynamic>.from(parsed['plan']),
        'preferences': data['preferences'],
        if (parsed['estimation_text'] != null)
          'estimation_text': parsed['estimation_text'].toString(),
      };
    }

    // Oldest case: raw array
    return {
      'plan': List<dynamic>.from(parsed),
      'preferences': data['preferences'],
    };
  }

  Future<Map<String, dynamic>> fetchPreferencesOnly() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/user/preferences/'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['preferences'];
    } else {
      throw Exception('Failed to fetch preferences');
    }
  }

  /// SAVE: persists a generated plan + optional estimation to backend.
  /// Pass [estimationText] if you already computed/decided it client-side;
  /// otherwise pass null (you can PATCH it later via [updateEstimationOnBackend]).
  Future<void> savePlanToBackend(
      String planTitle,
      List<WorkoutDay> workoutDays, {
        String? estimationText,
      }) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final body = {
      "planTitle": planTitle,
      "days": workoutDays.map((d) => d.toJson()).toList(),
      if (estimationText != null) "estimationText": estimationText,
    };

    final res = await http.post(
      Uri.parse('$baseUrl/workout-plans/save'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to save plan');
    }
  }

  /// Fetch ALL saved plans (array). Each item may include estimation_text.
  Future<Map<String, dynamic>> fetchSavedPlanFromBackend() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.get(
      Uri.parse('$baseUrl/workout-plans/my-plans'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // `data` is a List of plans { id, user_id, plan_title, days_json, estimation_text, created_at }
      return {
        'plans': data,
      };
    } else {
      throw Exception('Failed to fetch saved plans');
    }
  }

  /// Fetch the latest saved plan and normalize it for the editor.
  /// Returns: { plan: [ {plan_title: ...}, ...days ], meta: {...}, estimationText: String? }
  Future<Map<String, dynamic>> fetchLatestSavedPlan() async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    // Using /my-plans then picking latest to stay consistent with your current logic.
    final res = await http.get(
      Uri.parse('$baseUrl/workout-plans/my-plans'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load saved plans');
    }

    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty) {
      return {'plan': <dynamic>[], 'meta': {}, 'estimationText': null};
    }

    // pick the newest plan
    Map<String, dynamic> latest = Map<String, dynamic>.from(data.first);
    if (data.length > 1) {
      for (final e in data) {
        final m = Map<String, dynamic>.from(e);
        final cur = latest['created_at']?.toString();
        final nxt = m['created_at']?.toString();
        if (cur == null || (nxt != null && nxt.compareTo(cur) > 0)) {
          latest = m;
        }
      }
    }

    final String title = (latest['plan_title'] ?? 'Personalized Plan').toString();

    // days_json can be String or already-decoded JSON
    dynamic daysJson = latest['days_json'];
    if (daysJson is String && daysJson.isNotEmpty) {
      try {
        daysJson = jsonDecode(daysJson);
      } catch (_) {/* keep as is if not JSON */}
    }

    // Normalize to editor shape
    final List<dynamic> daysList;
    if (daysJson is List) {
      daysList = daysJson;
    } else if (daysJson is Map && daysJson['days'] is List) {
      daysList = List<dynamic>.from(daysJson['days']);
    } else {
      daysList = <dynamic>[];
    }

    final List<dynamic> planForEditor = [
      {'plan_title': title},
      ...daysList,
    ];

    // NEW: pull the server field
    final String? estimationText = latest['estimation_text']?.toString();

    return {
      'plan': planForEditor,
      'meta': {
        'id': latest['id'],
        'created_at': latest['created_at'],
        'title': title,
      },
      'estimationText': estimationText,
    };
  }

  /// OPTIONAL helper: update only the estimation text later.
  Future<void> updateEstimationOnBackend({
    required int planId,
    required String estimationText,
  }) async {
    final jwt = await secureStorage.read(key: 'jwt_cookie');
    final res = await http.patch(
      Uri.parse('$baseUrl/workout-plans/estimation'),
      headers: {
        'Cookie': 'session=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'planId': planId,
        'estimationText': estimationText,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update estimation');
    }
  }
}

extension AIFitnessPlanParsing on AIFitnessPlanService {
  List<WorkoutDay> parsePlanToModels(dynamic planJson) {
    if (planJson is List) {
      // Skip the first object if it's plan_title
      final daysList = planJson.length > 1 && planJson[0]['plan_title'] != null
          ? planJson.sublist(1)
          : planJson;

      return daysList.map<WorkoutDay>((dayJson) {
        final exercises = (dayJson['exercises'] as List?)
            ?.map<Exercise>((e) => Exercise.fromAiJson(e))
            .toList() ??
            [];
        return WorkoutDay(
          dayOfMonth: dayJson['day_of_month'],
          exercises: exercises,
          notes: dayJson['notes'] ?? '',
          isRest: dayJson['rest'] ?? false,
        );
      }).toList();
    }
    throw Exception('Plan format not recognized');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// -------------------- Models --------------------

class WorkoutPlan {
  final int planId;
  final String planTitle;
  final DateTime? createdAt;
  final int? itemsCount;

  WorkoutPlan({
    required this.planId,
    required this.planTitle,
    this.createdAt,
    this.itemsCount,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final id = json['plan_id'] ?? json['planId'];
    final title = json['plan_title'] ?? json['planTitle'];
    final created = json['created_at'] ?? json['createdAt'];
    final items = json['items_count'] ?? json['itemsCount'];

    return WorkoutPlan(
      planId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      planTitle: title?.toString() ?? '',
      createdAt: (created == null || created.toString().isEmpty)
          ? null
          : DateTime.tryParse(created.toString()),
      itemsCount: items == null ? null : (items is int ? items : int.tryParse(items.toString())),
    );
  }
}

/// Represents an item in a plan. On fetch, backend returns a JOIN:
/// SELECT i.item_id, i.plan_id, e.*
/// So we include both linkage fields and exercise details (nullable).
class WorkoutPlanItem {
  final int itemId;       // from i.item_id (present on fetch)
  final int planId;       // from i.plan_id (present on fetch)
  final int exerciseId;   // from i.exercise_id / e.exercise_id

  // Joined exercise fields (nullable to be forward-compatible)
  final String? exerciseName;
  final String? exerciseDescription;
  final int? exerciseSets;
  final int? exerciseReps;
  final String? exerciseInstructions;
  final String? exerciseLevel;
  final String? exerciseEquipment;
  final int? exerciseDuration;
  final String? youtubeUrl;
  final num? caloriesBurntPerRep;
  final int? workoutId;

  WorkoutPlanItem({
    required this.itemId,
    required this.planId,
    required this.exerciseId,
    this.exerciseName,
    this.exerciseDescription,
    this.exerciseSets,
    this.exerciseReps,
    this.exerciseInstructions,
    this.exerciseLevel,
    this.exerciseEquipment,
    this.exerciseDuration,
    this.youtubeUrl,
    this.caloriesBurntPerRep,
    this.workoutId,
  });

  /// Construct from the JOIN result.
  factory WorkoutPlanItem.fromJson(Map<String, dynamic> json) {
    // linkage fields
    final itemId = json['item_id'] ?? json['itemId'] ?? 0;
    final planId = json['plan_id'] ?? json['planId'] ?? 0;
    final exerciseId = json['exercise_id'] ?? json['exerciseId'] ?? 0;

    return WorkoutPlanItem(
      itemId: itemId is int ? itemId : int.tryParse(itemId.toString()) ?? 0,
      planId: planId is int ? planId : int.tryParse(planId.toString()) ?? 0,
      exerciseId: exerciseId is int ? exerciseId : int.tryParse(exerciseId.toString()) ?? 0,

      // exercise fields (joined)
      exerciseName: _s(json['exercise_name'] ?? json['exerciseName']),
      exerciseDescription: _s(json['exercise_description'] ?? json['exerciseDescription']),
      exerciseSets: _i(json['exercise_sets'] ?? json['exerciseSets']),
      exerciseReps: _i(json['exercise_reps'] ?? json['exerciseReps']),
      exerciseInstructions: _s(json['exercise_instructions'] ?? json['exerciseInstructions']),
      exerciseLevel: _s(json['exercise_level'] ?? json['exerciseLevel']),
      exerciseEquipment: _s(json['exercise_equipment'] ?? json['exerciseEquipment']),
      exerciseDuration: _i(json['exercise_duration'] ?? json['exerciseDuration']),
      youtubeUrl: _s(json['youtube_url'] ?? json['youtubeUrl']),
      caloriesBurntPerRep: _n(json['calories_burnt_per_rep'] ?? json['caloriesBurntPerRep']),
      workoutId: _i(json['workout_id'] ?? json['workoutId']),
    );
  }

  /// For POST /:planId/item we only send exercise_id.
  Map<String, dynamic> toCreateJson() => {
    'exercise_id': exerciseId,
  };

  static String? _s(dynamic v) => v == null ? null : v.toString();
  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static num? _n(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }
}

/// -------------------- Service --------------------

class CreateWorkoutPlanService {
  final String baseUrl;
  final FlutterSecureStorage _storage;

  CreateWorkoutPlanService({
    this.baseUrl = 'https://fyp-25-s2-08.onrender.com',
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  /// 1) Get my plans
  Future<List<WorkoutPlan>> getMyPlans() async {
    final res = await _get('/user-workout-plans');
    final data = _decodeJson(res);
    if (data is List) {
      return data.map((e) => WorkoutPlan.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Unexpected response format when fetching plans.');
  }

  /// 2) Create a plan
  Future<WorkoutPlan> createPlan({required String planTitle}) async {
    final res = await _post('/user-workout-plans', body: {
      'plan_title': planTitle,
    });
    final data = _decodeJson(res);
    final planId = (data['plan_id'] as int?) ?? int.tryParse('${data['plan_id'] ?? ''}');
    if (planId == null) {
      throw Exception('Plan created but no plan_id returned');
    }
    return WorkoutPlan(
      planId: planId,
      planTitle: (data['plan_title'] ?? planTitle).toString(),
    );
  }

  /// 3) Get items for a plan (JOIN result)
  Future<List<WorkoutPlanItem>> getPlanItems(int planId) async {
    final res = await _get('/user-workout-plans/$planId/items');
    final data = _decodeJson(res);
    if (data is List) {
      return data
          .map((e) => WorkoutPlanItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Unexpected response format when fetching items.');
  }

  /// 4) Delete a plan
  Future<void> deletePlan(int planId) async {
    final res = await _delete('/user-workout-plans/$planId');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to delete plan (${res.statusCode})');
    }
  }

  /// 5) Add one item (now expects only exercise_id)
  Future<int> addOneItem({
    required int planId,
    required int exerciseId,
  }) async {
    final item = WorkoutPlanItem(itemId: 0, planId: planId, exerciseId: exerciseId);
    final res = await _post('/user-workout-plans/$planId/item', body: item.toCreateJson());
    final data = _decodeJson(res);
    final itemId = data['item_id'] ?? data['id'];
    if (itemId == null) throw Exception('Item add returned no item_id');
    return (itemId is int) ? itemId : int.parse(itemId.toString());
  }

  /// 6) Add multiple items (optional; if backend exposes POST /:planId/items)
  /// Expects a list of exercise IDs.
  Future<int> addItemsBulk({
    required int planId,
    required List<int> exerciseIds,
  }) async {
    final body = {
      'items': exerciseIds.map((id) => {'exercise_id': id}).toList(),
    };
    final res = await _post('/user-workout-plans/$planId/items', body: body);
    final data = _decodeJson(res);
    final inserted = data['inserted_count'] ?? data['affectedRows'];
    return inserted is int ? inserted : int.tryParse(inserted.toString()) ?? 0;
  }

  // -------------------- HTTP helpers --------------------

  Future<String?> _getStoredToken() async {
    return _storage.read(key: 'jwt_cookie');
  }

  Map<String, String> _headersWithCookie(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Cookie'] = 'session=$token';
    }
    return headers;
  }

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<http.Response> _get(String path) async {
    final t = await _getStoredToken();
    final res = await http.get(_u(path), headers: _headersWithCookie(t));
    _throwIfNotOk(res);
    return res;
  }

  Future<http.Response> _post(String path, {Map<String, dynamic>? body}) async {
    final t = await _getStoredToken();
    final res = await http.post(
      _u(path),
      headers: _headersWithCookie(t),
      body: jsonEncode(body ?? {}),
    );
    _throwIfNotOk(res);
    return res;
  }

  Future<http.Response> _delete(String path) async {
    final t = await _getStoredToken();
    final res = await http.delete(_u(path), headers: _headersWithCookie(t));
    _throwIfNotOk(res);
    return res;
  }

  dynamic _decodeJson(http.Response res) {
    return res.body.isEmpty ? {} : jsonDecode(res.body);
  }

  void _throwIfNotOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}

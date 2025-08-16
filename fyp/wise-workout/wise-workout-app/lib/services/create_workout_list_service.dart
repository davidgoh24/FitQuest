import 'package:flutter/foundation.dart';
import 'create_workout_plan_service.dart';

class CreateWorkoutListService extends ChangeNotifier {
  final CreateWorkoutPlanService _planService;

  CreateWorkoutListService({CreateWorkoutPlanService? service})
      : _planService = service ?? CreateWorkoutPlanService();

  bool _loading = false;
  String? _error;
  List<WorkoutPlan> _plans = [];

  bool get loading => _loading;
  String? get error => _error;
  List<WorkoutPlan> get plans => List.unmodifiable(_plans);

  Future<void> loadPlans() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _planService.getMyPlans();
      _plans = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadPlans();

  /// Create a plan and refresh local cache
  Future<WorkoutPlan> createPlan(String title) async {
    final p = await _planService.createPlan(planTitle: title);
    await loadPlans();
    return p;
  }

  /// Delete a plan and update local list
  Future<void> deletePlan(int planId) async {
    await _planService.deletePlan(planId);
    _plans.removeWhere((p) => p.planId == planId);
    notifyListeners();
  }

  /// Get items for a plan (JOIN result from backend)
  Future<List<WorkoutPlanItem>> getItems(int planId) {
    return _planService.getPlanItems(planId);
  }

  // -------------------- Add Items (updated API) --------------------

  /// Add a single exercise to a plan by exerciseId
  Future<int> addOneItem({
    required int planId,
    required int exerciseId,
  }) async {
    final id = await _planService.addOneItem(
      planId: planId,
      exerciseId: exerciseId,
    );
    return id;
  }

  /// Add multiple exercises (list of exerciseIds) to a plan
  Future<int> addItemsBulk({
    required int planId,
    required List<int> exerciseIds,
  }) async {
    final count = await _planService.addItemsBulk(
      planId: planId,
      exerciseIds: exerciseIds,
    );
    return count;
  }
}

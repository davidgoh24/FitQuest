class WorkoutPlanItem {
  final int? itemId;
  final int? planId;
  final String exerciseName;
  final int? exerciseReps;
  final int? exerciseSets;
  final int? exerciseDuration;

  WorkoutPlanItem({
    this.itemId,
    this.planId,
    required this.exerciseName,
    this.exerciseReps,
    this.exerciseSets,
    this.exerciseDuration,
  });

  factory WorkoutPlanItem.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanItem(
      itemId: json['item_id'],
      planId: json['plan_id'],
      exerciseName: json['exercise_name'] ?? '',
      exerciseReps: json['exercise_reps'],
      exerciseSets: json['exercise_sets'],
      exerciseDuration: json['exercise_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_name': exerciseName,
      'exercise_reps': exerciseReps,
      'exercise_sets': exerciseSets,
      'exercise_duration': exerciseDuration,
    };
  }
}
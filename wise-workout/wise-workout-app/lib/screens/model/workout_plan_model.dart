import 'workout_plan_item_model.dart';

class WorkoutPlan {
  final int planId;
  final int userId;
  final String planTitle;
  final DateTime? createdAt;
  final int? itemsCount;
  final List<WorkoutPlanItem>? items;

  WorkoutPlan({
    required this.planId,
    required this.userId,
    required this.planTitle,
    this.createdAt,
    this.itemsCount,
    this.items,
  });

  factory WorkoutPlan.fromJsonListRow(Map<String, dynamic> json) {
    return WorkoutPlan(
      planId: json['plan_id'],
      userId: json['user_id'],
      planTitle: json['plan_title'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      itemsCount: json['items_count'],
    );
  }

  factory WorkoutPlan.fromJsonWithItems(Map<String, dynamic> json) {
    return WorkoutPlan(
      planId: json['plan_id'],
      userId: json['user_id'],
      planTitle: json['plan_title'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => WorkoutPlanItem.fromJson(e))
          .toList(),
    );
  }
}
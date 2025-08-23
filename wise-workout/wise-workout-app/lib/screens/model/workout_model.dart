class Workout {
  final int workoutId;
  final String workoutName;
  final String categoryKey;
  final String workoutLevel;
  final String workoutDescription;

  Workout({
    required this.workoutId,
    required this.categoryKey,
    required this.workoutName,
    required this.workoutLevel,
    required this.workoutDescription,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    workoutId: int.tryParse(json['workoutId'].toString()) ?? 0,
    categoryKey: json['categoryKey'],
    workoutName: json['workoutName'],
    workoutLevel: json['workoutLevel'],
    workoutDescription: json['workoutDescription'],
  );
}

class Exercise {
  final String exerciseId;
  final String exerciseKey;
  final String exerciseName;
  final String exerciseDescription;
  final int exerciseSets;
  final int exerciseReps;
  final String exerciseInstructions;
  final String exerciseLevel;
  final String exerciseEquipment;
  final int? exerciseDuration;
  final String youtubeUrl;
  final int workoutId;
  final double? exerciseWeight;
  final double? calories_burnt_per_rep;

  Exercise({
    required this.exerciseId,
    required this.exerciseKey,
    required this.exerciseName,
    required this.exerciseDescription,
    required this.exerciseSets,
    required this.exerciseReps,
    required this.exerciseInstructions,
    required this.exerciseLevel,
    required this.exerciseEquipment,
    this.exerciseDuration,
    required this.youtubeUrl,
    required this.workoutId,
    this.exerciseWeight,
    this.calories_burnt_per_rep,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseKey': exerciseKey,
      'exerciseName': exerciseName,
      'exerciseDescription': exerciseDescription,
      'exerciseSets': exerciseSets,
      'exerciseReps': exerciseReps,
      'exerciseInstructions': exerciseInstructions,
      'exerciseLevel': exerciseLevel,
      'exerciseEquipment': exerciseEquipment,
      'exerciseDuration': exerciseDuration,
      'youtubeUrl': youtubeUrl,
      'workoutId': workoutId,
      'exerciseWeight': exerciseWeight,
      'caloriesBurntPerRep': calories_burnt_per_rep,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'].toString(),
      exerciseKey: json['exerciseKey'],
      exerciseName: json['exerciseName'],
      exerciseDescription: json['exerciseDescription'],
      exerciseSets: int.tryParse(json['exerciseSets'].toString()) ?? 0,
      exerciseReps: int.tryParse(json['exerciseReps'].toString()) ?? 0,
      exerciseInstructions: json['exerciseInstructions'],
      exerciseLevel: json['exerciseLevel'],
      exerciseEquipment: json['exerciseEquipment'],
      exerciseDuration: json['exerciseDuration'] != null
          ? int.tryParse(json['exerciseDuration'].toString())
          : null,
      youtubeUrl: json['youtubeUrl'],
      workoutId: int.tryParse(json['workoutId'].toString()) ?? 0,
      exerciseWeight: json['exerciseWeight'] != null
          ? double.tryParse(json['exerciseWeight'].toString())
          : null,
      calories_burnt_per_rep: json['calories_burnt_per_rep'] != null
          ? double.tryParse(json['calories_burnt_per_rep'].toString())
          : null,
    );
  }

  factory Exercise.fromAiJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: '',
      exerciseKey: '',
      exerciseName: json['name'] ?? '',
      exerciseDescription: '',
      exerciseSets: int.tryParse(json['sets'].toString()) ?? 0,
      exerciseReps: int.tryParse(json['reps'].toString()) ?? 0,
      exerciseInstructions: '',
      exerciseLevel: '',
      exerciseEquipment: '',
      exerciseDuration: null,
      youtubeUrl: '',
      workoutId: 0,
      exerciseWeight: null,
      calories_burnt_per_rep: json['caloriesBurntPerRep'] != null
          ? double.tryParse(json['caloriesBurntPerRep'].toString())
          : null,
    );
  }
}

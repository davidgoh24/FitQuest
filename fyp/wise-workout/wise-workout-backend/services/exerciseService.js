const ExerciseModel = require('../models/exerciseModel');

class ExerciseService {
  static async getExercisesByWorkout(workoutId) {
    return await ExerciseModel.getExercisesByWorkoutId(workoutId);
  }

  static async getExercisesByNames(names) {
    return await ExerciseModel.getExercisesByNames(names);
  }

  static async getAllExercises() {
    return await ExerciseModel.getAllExercises();
  }
}

module.exports = ExerciseService;
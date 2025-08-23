const WorkoutModel = require('../models/workoutModel');

class WorkoutService {
  static async getWorkoutsByCategory(categoryKey) {
    return await WorkoutModel.getWorkoutsByCategoryKey(categoryKey);
  }

  static async getWorkoutById(workoutId) {
    return await WorkoutModel.getWorkoutById(workoutId);
  }
}

module.exports = WorkoutService;

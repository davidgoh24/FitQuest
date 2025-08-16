const db = require('../config/db');

class WorkoutModel {
  static async getWorkoutsByCategoryKey(categoryKey) {
    const [rows] = await db.execute(`
      SELECT
        workout_id AS workoutId,
        workout_name AS workoutName,
        category_key AS categoryKey,
        workout_level AS workoutLevel,
        workout_description AS workoutDescription
      FROM workouts
      WHERE category_key = ?
    `, [categoryKey]);

    return rows;
  }

  static async getWorkoutById(workoutId) {
    const [rows] = await db.execute(`
      SELECT
        workout_id AS workoutId,
        workout_name AS workoutName,
        category_key AS categoryKey,
        workout_level AS workoutLevel,
        workout_description AS workoutDescription
      FROM workouts
      WHERE workout_id = ?
    `, [workoutId]);

    return rows[0];
  }
}

module.exports = WorkoutModel;

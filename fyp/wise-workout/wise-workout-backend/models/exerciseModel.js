const db = require('../config/db');

class ExerciseModel {
  static async getExercisesByWorkoutId(workoutId) {
    const [rows] = await db.execute(`
      SELECT
        exercise_id AS exerciseId,
        exercise_key AS exerciseKey,
        exercise_name AS exerciseName,
        exercise_description AS exerciseDescription,
        exercise_sets AS exerciseSets,
        exercise_reps AS exerciseReps,
        exercise_instructions AS exerciseInstructions,
        exercise_level AS exerciseLevel,
        exercise_equipment AS exerciseEquipment,
        exercise_duration AS exerciseDuration,
        youtube_url AS youtubeUrl,
        workout_id AS workoutId,
        calories_burnt_per_rep AS calories_burnt_per_rep
      FROM exercises
      WHERE workout_id = ?
    `, [workoutId]);

    return rows;
  }

  static async getAllExercises() {
    const [rows] = await db.execute(`
      SELECT
        exercise_id AS exerciseId,
        exercise_key AS exerciseKey,
        exercise_name AS exerciseName,
        exercise_description AS exerciseDescription,
        exercise_sets AS exerciseSets,
        exercise_reps AS exerciseReps,
        exercise_instructions AS exerciseInstructions,
        exercise_level AS exerciseLevel,
        exercise_equipment AS exerciseEquipment,
        exercise_duration AS exerciseDuration,
        youtube_url AS youtubeUrl,
        workout_id AS workoutId
      FROM exercises
    `);

    return rows;
  }

static async getExercisesByNames(names) {
    if (!Array.isArray(names) || names.length === 0) return [];
    const placeholders = names.map(() => '?').join(',');
    const [rows] = await db.execute(`
      SELECT
        exercise_id AS exerciseId,
        exercise_key AS exerciseKey,
        exercise_name AS exerciseName,
        exercise_description AS exerciseDescription,
        exercise_sets AS exerciseSets,
        exercise_reps AS exerciseReps,
        exercise_instructions AS exerciseInstructions,
        exercise_level AS exerciseLevel,
        exercise_equipment AS exerciseEquipment,
        exercise_duration AS exerciseDuration,
        youtube_url AS youtubeUrl,
        workout_id AS workoutId,
        calories_burnt_per_rep AS calories_burnt_per_rep
      FROM exercises
      WHERE exercise_name IN (${placeholders})
    `, names);

    return rows;
}
}

module.exports = ExerciseModel;

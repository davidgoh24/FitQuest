const db = require('../config/db');

class WorkoutSessionModel {
  static async createSession({ userId, workoutId, startTime, endTime, duration, caloriesBurned, notes }) {
    const [result] = await db.execute(
      `INSERT INTO workout_sessions (user_id, workout_id, start_time, end_time, duration, calories_burned, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, workoutId, startTime, endTime, duration, caloriesBurned, notes]
    );
    return result.insertId;
  }

  static async getSessionsByUserId(userId) {
    const [rows] = await db.execute(
      `SELECT 
        ws.session_id,
        ws.workout_id,
        ws.start_time,
        ws.end_time,
        ws.duration,
        ws.calories_burned,
        ws.notes,
        ws.created_at,
        w.workout_name
      FROM workout_sessions ws
      LEFT JOIN workouts w ON ws.workout_id = w.workout_id
      WHERE ws.user_id = ?
      ORDER BY ws.start_time DESC`,
      [userId]
    );
    return rows;
  }

  static async countSessionsByUserId(userId) {
    const [rows] = await db.execute(
      'SELECT COUNT(*) as session_count FROM workout_sessions WHERE user_id = ?',
      [userId]
    );
    return rows[0].session_count;
  }

  static async getTotalCaloriesBurnedByUserId(userId) {
    const [rows] = await db.execute(
      'SELECT SUM(calories_burned) as total_calories FROM workout_sessions WHERE user_id = ?',
      [userId]
    );
    return rows[0].total_calories || 0;
  }

  static async getTodayCaloriesSummaryByUserId(userId) {
    const [rows] = await db.execute(
      `SELECT
          COALESCE(SUM(calories_burned), 0) AS total_calories,
          MIN(start_time) AS first_start_time
       FROM workout_sessions
       WHERE user_id = ?
         AND DATE(start_time) = CURDATE()`,
      [userId]
    );

    return {
      total_calories: Number(rows[0]?.total_calories || 0),
      first_start_time: rows[0]?.first_start_time || null,
    };
  }

  static async getTodayCaloriesByUserId(userId) {
    const [rows] = await db.execute(
      `SELECT COALESCE(SUM(calories_burned), 0) AS total_calories
         FROM workout_sessions
        WHERE user_id = ?
          AND DATE(start_time) = CURDATE()`,
      [userId]
    );
    return Number(rows[0]?.total_calories || 0);
  }

  static async getDailyCaloriesByUserIdInRange(userId, fromDate, toDate) {
    const [rows] = await db.execute(
      `SELECT
          DATE(start_time) AS day,
          COALESCE(SUM(calories_burned), 0) AS total_calories
       FROM workout_sessions
       WHERE user_id = ?
         AND start_time >= ?
         AND start_time < DATE_ADD(?, INTERVAL 1 DAY)
       GROUP BY DATE(start_time)
       ORDER BY day ASC`,
      [userId, fromDate, toDate]
    );
    return rows;
  }

  static async getHourlyCaloriesByUserAndDate(userId, ymd) {
    const [rows] = await db.execute(
      `SELECT
         HOUR(start_time) AS hour,
         COALESCE(SUM(calories_burned), 0) AS calories
       FROM workout_sessions
       WHERE user_id = ?
         AND DATE(start_time) = ?
       GROUP BY HOUR(start_time)
       ORDER BY hour`,
      [userId, ymd]
    );
    return rows;
  }
  static async getSessionIntensity(sessionId) {
    const [rows] = await db.execute(
      `SELECT w.workout_level AS intensity
       FROM workout_sessions ws
       LEFT JOIN workouts w ON ws.workout_id = w.workout_id
       WHERE ws.session_id = ?`,
      [sessionId]
    );
    return rows[0]?.intensity || null;
  }  
}

module.exports = WorkoutSessionModel;

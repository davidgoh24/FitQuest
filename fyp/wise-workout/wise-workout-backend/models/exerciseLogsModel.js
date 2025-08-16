const db = require('../config/db');

class ExerciseLogModel {
  static async logExercise(sessionId, { exerciseKey, exerciseName, setsData }) {
    const [result] = await db.execute(
      `INSERT INTO exercise_logs (session_id, exercise_key, exercise_name, sets_data)
       VALUES (?, ?, ?, ?)`,
      [sessionId, exerciseKey, exerciseName, JSON.stringify(setsData)]
    );
    return result.insertId;
  }

  static async getExerciseLogsBySessionId(sessionId) {
    const [rows] = await db.execute(
      `SELECT 
        log_id,
        exercise_key,
        exercise_name,
        sets_data,
        created_at
      FROM exercise_logs
      WHERE session_id = ?
      ORDER BY created_at ASC`,
      [sessionId]
    );
  
    return rows.map(row => {
      let parsedSetsData = [];
      if (typeof row.sets_data === 'string') {
        try {
          parsedSetsData = JSON.parse(row.sets_data);
        } catch (e) {
          console.error('Invalid JSON in sets_data for log_id:', row.log_id, 'Value:', row.sets_data);
          parsedSetsData = [];
        }
      } else if (Array.isArray(row.sets_data) || typeof row.sets_data === 'object') {
        parsedSetsData = row.sets_data;
      } else {
        parsedSetsData = [];
      }
      return {
        ...row,
        sets_data: parsedSetsData
      };
    });
  }
  
}

module.exports = ExerciseLogModel;

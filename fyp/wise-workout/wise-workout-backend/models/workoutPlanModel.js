const db = require('../config/db');

class WorkoutPlanModel {
  static async saveWorkoutPlan(userId, planTitle, daysJson, estimationText = null) {
    await db.execute('DELETE FROM workout_plans WHERE user_id = ?', [userId]);

    const [result] = await db.execute(
      `INSERT INTO workout_plans (user_id, plan_title, days_json, estimation_text, created_at)
       VALUES (?, ?, ?, ?, NOW())`,
      [userId, planTitle, JSON.stringify(daysJson), estimationText]
    );
    return result.insertId;
  }

  static async getWorkoutPlansByUser(userId) {
    const [rows] = await db.execute(
      `SELECT id, user_id, plan_title, days_json, estimation_text, created_at
         FROM workout_plans
        WHERE user_id = ?
     ORDER BY created_at DESC`,
      [userId]
    );
    return rows;
  }

  static async getLatestWorkoutPlanByUser(userId) {
    const [rows] = await db.execute(
      `SELECT id, user_id, plan_title, days_json, estimation_text, created_at
         FROM workout_plans
        WHERE user_id = ?
     ORDER BY created_at DESC, id DESC
        LIMIT 1`,
      [userId]
    );
    return rows[0] || null;
  }

  // Optional helpers if you need them elsewhere
  static async updateEstimation(planId, estimationText) {
    const [res] = await db.execute(
      `UPDATE workout_plans
          SET estimation_text = ?
        WHERE id = ?`,
      [estimationText, planId]
    );
    return res.affectedRows > 0;
  }

  static async getById(planId) {
    const [rows] = await db.execute(
      `SELECT id, user_id, plan_title, days_json, estimation_text, created_at
         FROM workout_plans
        WHERE id = ?`,
      [planId]
    );
    return rows[0] || null;
  }

  static async getLatestWorkoutPlan(userId) {
      const [rows] = await db.execute(
        `SELECT id, user_id, plan_title, days_json, created_at
           FROM workout_plans
          WHERE user_id = ?
       ORDER BY created_at DESC, id DESC
          LIMIT 1`,
        [userId]
      );
      return rows[0] || null;
    }
}

module.exports = WorkoutPlanModel;

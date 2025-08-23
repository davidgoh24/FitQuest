const db = require('../config/db');

class UserWorkoutPlanModel {
  static async getPlansByUserId(userId) {
    const [rows] = await db.execute(
      `SELECT plan_id, plan_title, created_at
       FROM user_workout_plan
       WHERE user_id = ?`,
      [userId]
    );
    return rows;
  }

  static async createPlan(userId, planTitle) {
    const [result] = await db.execute(
      `INSERT INTO user_workout_plan (user_id, plan_title)
       VALUES (?, ?)`,
      [userId, planTitle]
    );
    return result.insertId;
  }

  // ✅ Now joins with exercises table to get all exercise info
  static async getItemsByPlanId(planId) {
    const [rows] = await db.execute(
      `SELECT i.item_id, i.plan_id, e.*
       FROM user_workout_plan_items i
       JOIN exercises e ON e.exercise_id = i.exercise_id
       WHERE i.plan_id = ?`,
      [planId]
    );
    return rows;
  }

  static async deletePlan(planId, userId) {
    const [result] = await db.execute(
      `DELETE FROM user_workout_plan
       WHERE plan_id = ? AND user_id = ?`,
      [planId, userId]
    );
    return result.affectedRows > 0;
  }

  // ✅ Now stores exercise_id instead of name/reps/sets/duration
  static async addItemForUser(userId, planId, item) {
    // ensure plan belongs to user
    const [own] = await db.execute(
      'SELECT 1 FROM user_workout_plan WHERE plan_id = ? AND user_id = ? LIMIT 1',
      [planId, userId]
    );
    if (own.length === 0) return null;

    const { exercise_id } = item;
    if (!exercise_id) return null;

    const [res] = await db.execute(
      `INSERT INTO user_workout_plan_items (plan_id, exercise_id)
       VALUES (?, ?)`,
      [planId, exercise_id]
    );
    return res.insertId;
  }
}

module.exports = UserWorkoutPlanModel;

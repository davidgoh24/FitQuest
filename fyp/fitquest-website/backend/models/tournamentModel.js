const db = require('../config/db');

class TournamentModel {
  static async insertTournament({
    title, description, startDate, endDate, features, target_exercise_pattern,
    reward_xp_first, reward_xp_second, reward_xp_other,
    reward_tokens_first, reward_tokens_second, reward_tokens_other
  }) {
    const [result] = await db.execute(
      `INSERT INTO tournaments (
        title, description, startDate, endDate, features, target_exercise_pattern,
        reward_xp_first, reward_xp_second, reward_xp_other,
        reward_tokens_first, reward_tokens_second, reward_tokens_other
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        title, description, startDate, endDate, features, target_exercise_pattern,
        reward_xp_first, reward_xp_second, reward_xp_other,
        reward_tokens_first, reward_tokens_second, reward_tokens_other
      ]
    );
    return { id: result.insertId };
  }

  static async getAllTournaments() {
    const [rows] = await db.execute(
      `SELECT 
        id, title, description, startDate, endDate, features, target_exercise_pattern, rewarded,
        reward_xp_first, reward_xp_second, reward_xp_other,
        reward_tokens_first, reward_tokens_second, reward_tokens_other
       FROM tournaments
       ORDER BY created_at DESC`
    );
    return rows;
  }

  static async updateTournament(id, {
    title, description, startDate, endDate, features, target_exercise_pattern,
    reward_xp_first, reward_xp_second, reward_xp_other,
    reward_tokens_first, reward_tokens_second, reward_tokens_other
  }) {
    await db.execute(
      `UPDATE tournaments
       SET title=?, description=?, startDate=?, endDate=?, features=?, target_exercise_pattern=?,
           reward_xp_first=?, reward_xp_second=?, reward_xp_other=?,
           reward_tokens_first=?, reward_tokens_second=?, reward_tokens_other=?
       WHERE id=?`,
      [
        title, description, startDate, endDate, features, target_exercise_pattern,
        reward_xp_first, reward_xp_second, reward_xp_other,
        reward_tokens_first, reward_tokens_second, reward_tokens_other,
        id
      ]
    );
    return { message: 'Tournament updated successfully' };
  }
}

module.exports = TournamentModel;

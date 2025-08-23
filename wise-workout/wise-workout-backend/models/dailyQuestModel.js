const db = require('../config/db');

class DailyQuestModel {
  static async getQuests() {
    const [rows] = await db.execute('SELECT * FROM quests');
    return rows;
  }

  static async getUserDailyQuests(userId, dateStr) {
    const [rows] = await db.execute(
      `SELECT udq.*, q.text, q.xp_reward
       FROM user_daily_quests udq
       JOIN quests q ON udq.quest_code = q.code
       WHERE udq.user_id = ? AND udq.quest_date = ?`,
      [userId, dateStr]
    );
    return rows;
  }

  static async insertUserDailyQuest(userId, questCode, dateStr) {
    await db.execute(
      `INSERT IGNORE INTO user_daily_quests (user_id, quest_code, quest_date)
       VALUES (?, ?, ?)`, [userId, questCode, dateStr]);
  }

  static async markQuestClaimed(userId, questCode, dateStr) {
    await db.execute(
      `UPDATE user_daily_quests
       SET claimed = 1, claimed_at = NOW()
       WHERE user_id = ? AND quest_code = ? AND quest_date = ? AND done = 1 AND claimed = 0`,
      [userId, questCode, dateStr]
    );
  }

  static async getQuestRow(userId, questCode, dateStr) {
    const [rows] = await db.execute(
      `SELECT udq.*, q.xp_reward
       FROM user_daily_quests udq
       JOIN quests q ON udq.quest_code = q.code
       WHERE udq.user_id = ? AND udq.quest_code = ? AND udq.quest_date = ?`,
      [userId, questCode, dateStr]
    );
    return rows[0];
  }

  static async getDoneUnclaimed(userId, dateStr) {
    const [rows] = await db.execute(
      `SELECT udq.*, q.xp_reward
       FROM user_daily_quests udq
       JOIN quests q ON udq.quest_code = q.code
       WHERE udq.user_id = ? AND udq.quest_date = ? AND udq.done = 1 AND udq.claimed = 0`,
      [userId, dateStr]
    );
    return rows;
  }
  static async markQuestDone(userId, questCode, dateStr) {
    await db.execute(
      `UPDATE user_daily_quests SET done = 1, completed_at = NOW()
      WHERE user_id = ? AND quest_code = ? AND quest_date = ? AND done = 0`,
      [userId, questCode, dateStr]
    );
  }
}

module.exports = DailyQuestModel;

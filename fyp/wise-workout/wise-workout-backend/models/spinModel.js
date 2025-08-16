const db = require('../config/db');

class SpinModel {
  static async hasSpunToday(userId) {
    const [rows] = await db.execute(
      'SELECT * FROM spin_history WHERE user_id = ? AND DATE(spun_at) = CURDATE()',
      [userId]
    );
    return rows.length > 0;
  }

  static async getLastSpin(userId) {
    const [rows] = await db.execute(
      'SELECT spun_at FROM spin_history WHERE user_id = ? ORDER BY spun_at DESC LIMIT 1',
      [userId]
    );
    return rows[0] || null;
  }


  static async logSpin(userId, prize) {
    await db.execute(
      'INSERT INTO spin_history (user_id, prize_label, prize_type, prize_value) VALUES (?, ?, ?, ?)',
      [userId, prize.label, prize.type, prize.value]
    );
  }
  static async countUserSpins(userId) {
    const [rows] = await db.execute(
      'SELECT COUNT(*) as count FROM spin_history WHERE user_id = ?',
      [userId]
    );
    return rows[0].count;
  }
}

module.exports = SpinModel;

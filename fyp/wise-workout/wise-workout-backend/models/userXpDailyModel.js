const db = require('../config/db');

class UserXpDailyModel {
  static async getDailyXP(userId, date) {
    const [rows] = await db.execute(
      'SELECT xp_amount FROM user_xp_daily WHERE user_id = ? AND date = ?',
      [userId, date]
    );
    return rows[0]?.xp_amount || 0;
  }

//   static async getXPRange(userId, startDate, endDate) {
//     const [rows] = await db.execute(
//       'SELECT date, xp_amount FROM user_xp_daily WHERE user_id = ? AND date BETWEEN ? AND ? ORDER BY date ASC',
//       [userId, startDate, endDate]
//     );
//     return rows;
//   } In case we need
}

module.exports = UserXpDailyModel;

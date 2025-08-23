const db = require('../config/db');

class BadgeModel {
  static async getAllBadges() {
    const [rows] = await db.execute('SELECT * FROM badges');
    return rows;
  }

  static async getUserBadges(userId) {
    const [rows] = await db.execute(
      `SELECT b.* FROM badges b
       JOIN user_badges ub ON b.id = ub.badge_id
       WHERE ub.user_id = ?`,
      [userId]
    );
    return rows;
  }

  static async grantBadge(userId, badgeId) {
    await db.execute(
      'INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, ?)',
      [userId, badgeId]
    );
  }
}

module.exports = BadgeModel;

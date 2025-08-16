const db = require('../config/db');

class FeedbackModel {
  static async findByUserId(userId) {
    const [rows] = await db.execute(
      `SELECT liked_features, problems 
       FROM feedback 
       WHERE user_id = ? 
       ORDER BY created_at DESC 
       LIMIT 1`, 
      [userId]
    );
    return rows[0] || null;
  }
  
  static async findAllWithUser({ status = 'All', search = '' } = {}) {
    let query = `
      SELECT f.*, u.username, u.email, u.role, u.avatar_id
      FROM feedback f
      LEFT JOIN users u ON u.id = f.user_id
      WHERE 1
    `;
    let params = [];
    if (status && status !== 'All') {
      query += ' AND f.status = ?';
      params.push(status.toLowerCase());
    }
    if (search) {
      query += ' AND (u.username LIKE ? OR u.email LIKE ? OR f.message LIKE ?)';
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    query += ' ORDER BY f.created_at DESC';
    const [rows] = await db.execute(query, params);
    return rows;
  }
  static async updateStatus(id, status) {
    await db.execute('UPDATE feedback SET status = ? WHERE id = ?', [status, id]);
  }
  static async getRatingsData() {
    return db.execute(`
      SELECT 
        ROUND(AVG(rating), 2) AS averageRating,
        SUM(rating = 5) AS star5,
        SUM(rating = 4) AS star4,
        SUM(rating = 3) AS star3,
        SUM(rating = 2) AS star2,
        SUM(rating = 1) AS star1
      FROM feedback
    `);
  }
  
  static async getLikedFeaturesRows() {
    return db.execute(`
      SELECT JSON_UNQUOTE(JSON_EXTRACT(f.liked_features, CONCAT('$[', n.n, ']'))) AS feature
      FROM feedback f
      JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      ) n
        ON JSON_EXTRACT(f.liked_features, CONCAT('$[', n.n, ']')) IS NOT NULL
      WHERE f.liked_features IS NOT NULL
    `);
  }
  
  static async getIssuesRows() {
    return db.execute(`
      SELECT JSON_UNQUOTE(JSON_EXTRACT(f.problems, CONCAT('$[', n.n, ']'))) AS feature
      FROM feedback f
      JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      ) n
        ON JSON_EXTRACT(f.problems, CONCAT('$[', n.n, ']')) IS NOT NULL
      WHERE f.problems IS NOT NULL
    `);
  }
  
  static async getRecentReviews(limit) {
    const safeLimit = Number(limit) || 10;
    return db.execute(`
      SELECT 
        u.username,
        COALESCE(MAX(l.level), 1) AS level,
        f.rating,
        f.message,
        DATE_FORMAT(f.created_at, '%Y-%m-%d %H:%i:%s') AS created_at
      FROM feedback f
      LEFT JOIN users u ON u.id = f.user_id
      LEFT JOIN levels l ON u.xp >= l.xp_required
      GROUP BY f.id
      ORDER BY f.created_at DESC
      LIMIT ${safeLimit}
    `);
  }  
}

module.exports = FeedbackModel;

const db = require('../config/db');

class SubscriptionHistoryModel {
  static async findAllWithUser({ plan = 'All', search = '' } = {}) {
    let query = `
      SELECT sh.*, u.username, u.email, u.role
      FROM subscription_history sh
      LEFT JOIN users u ON u.id = sh.user_id
      WHERE 1
    `;
    const params = [];

    if (plan && plan !== 'All') {
      query += ' AND sh.plan = ?';
      params.push(plan.toLowerCase());
    }

    if (search) {
      query += ' AND (u.username LIKE ? OR u.email LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY sh.created_at DESC';
    const [rows] = await db.execute(query, params);
    return rows;
  }

  static async findByUserId(userId) {
    const [rows] = await db.execute(`
      SELECT sh.*, 
             u.username, 
             u.email, 
             u.role, 
             u.firstName, 
             u.lastName, 
             u.dob
      FROM subscription_history sh
      LEFT JOIN users u ON u.id = sh.user_id
      WHERE u.id = ?
      ORDER BY sh.created_at DESC
    `, [userId]);
    return rows;
  }  
}

module.exports = SubscriptionHistoryModel;

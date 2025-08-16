const db = require('../config/db');

class SubscriptionHistoryModel {
  static async insert({ userId, plan, method, amount, tokensUsed, startDate, endDate }) {
    const sql = `
      INSERT INTO subscription_history 
      (user_id, plan, method, amount, tokens_used, start_date, end_date)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    await db.execute(sql, [userId, plan, method, amount, tokensUsed, startDate, endDate]);
  }
}

module.exports = SubscriptionHistoryModel;

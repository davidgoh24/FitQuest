const db = require('../config/db');

class FeedbackModel {
  static async addFeedback(userId, feedbackData) {
    const { message, rating, liked_features, problems } = feedbackData;
    await db.execute(
      'INSERT INTO feedback (user_id, message, rating, liked_features, problems, status) VALUES (?, ?, ?, ?, ?, "pending")',
      [
        userId,
        message,
        rating,
        JSON.stringify(liked_features || []),
        JSON.stringify(problems || [])
      ]
    );
  }

  static async getPublishedFeedback() {
    const [rows] = await db.execute(
      `SELECT f.*, u.username, u.firstName, u.lastName, a.image_url as avatar_url
       FROM feedback f
       JOIN users u ON f.user_id = u.id
       LEFT JOIN avatars a ON u.avatar_id = a.id
       WHERE f.status = "accepted"
       ORDER BY f.created_at DESC`
    );
    return rows.map(row => ({
      ...row,
      liked_features: Array.isArray(row.liked_features)
        ? row.liked_features
        : (row.liked_features ? JSON.parse(row.liked_features) : []),
      problems: Array.isArray(row.problems)
        ? row.problems
        : (row.problems ? JSON.parse(row.problems) : [])
    }));    
  }
}

module.exports = FeedbackModel;

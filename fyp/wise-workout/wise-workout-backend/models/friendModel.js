const db = require('../config/db');

class FriendModel {
  static async sendRequest(userId, friendId) {
    const [result] = await db.execute(
      'INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, "pending")',
      [userId, friendId]
    );
    return result;
  }

  static async acceptRequest(userId, friendId) {
    await db.execute(
      'UPDATE friends SET status = "accepted" WHERE user_id = ? AND friend_id = ? AND status = "pending"',
      [friendId, userId]
    );
    await db.execute(
      'INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, "accepted")',
      [userId, friendId]
    );
  }

  static async rejectRequest(userId, friendId) {
    await db.execute(
      'UPDATE friends SET status = "rejected" WHERE user_id = ? AND friend_id = ? AND status = "pending"',
      [friendId, userId]
    );
  }

  static async getFriends(userId) {
    const [rows] = await db.execute(
      `SELECT u.id, u.username, u.firstName, u.lastName, u.email, u.role, 
              a.image_url as avatar_url, b.image_url as background_url
      FROM friends f
      JOIN users u ON u.id = f.friend_id
      LEFT JOIN avatars a ON u.avatar_id = a.id
      LEFT JOIN backgrounds b ON u.background_id = b.id
      WHERE f.user_id = ? AND f.status = "accepted"`,
      [userId]
    );
    return rows;
  }

  static async getPendingRequests(userId) {
    const [rows] = await db.execute(
      `SELECT u.id, u.username, u.firstName, u.lastName, u.email, u.role, 
              a.image_url as avatar_url, b.image_url as background_url
      FROM friends f
      JOIN users u ON u.id = f.user_id
      LEFT JOIN avatars a ON u.avatar_id = a.id
      LEFT JOIN backgrounds b ON u.background_id = b.id
      WHERE f.friend_id = ? AND f.status = "pending"`,
      [userId]
    );
    return rows;
  }

  static async getSentRequests(userId) {
    const [rows] = await db.execute(
      `SELECT u.id, u.username, u.firstName, u.lastName, u.email, u.role, 
              a.image_url as avatar_url, b.image_url as background_url
      FROM friends f
      JOIN users u ON u.id = f.friend_id
      LEFT JOIN avatars a ON u.avatar_id = a.id
      LEFT JOIN backgrounds b ON u.background_id = b.id
      WHERE f.user_id = ? AND f.status = "pending"`,
      [userId]
    );
    return rows;
  }

  static async getPremiumFriends(userId) {
    const [rows] = await db.execute(
      `SELECT u.id, u.username, u.firstName, u.lastName, u.email, u.role,
              a.image_url as avatar_url, b.image_url as background_url
       FROM friends f
       JOIN users u ON u.id = f.friend_id
       LEFT JOIN avatars a ON u.avatar_id = a.id
       LEFT JOIN backgrounds b ON u.background_id = b.id
       WHERE f.user_id = ? AND f.status = "accepted" AND u.role = "premium"`,
      [userId]
    );
    return rows;
  }
}

module.exports = FriendModel;

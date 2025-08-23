const db = require('../config/db');
const { encrypt, decrypt } = require('../utils/encryption');

class MessageModel {
  static async sendMessage(senderId, receiverId, content) {
    const encryptedContent = encrypt(content);
    const [result] = await db.execute(
      'INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)',
      [senderId, receiverId, encryptedContent]
    );
    return result;
  }

  static async getConversation(userId1, userId2) {
    const [rows] = await db.execute(
      `SELECT m.*, 
              u1.username AS sender_username,
              a1.image_url AS sender_avatar,
              b1.image_url AS sender_background
      FROM messages m
      JOIN users u1 ON m.sender_id = u1.id
      LEFT JOIN avatars a1 ON u1.avatar_id = a1.id
      LEFT JOIN backgrounds b1 ON u1.background_id = b1.id
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
      ORDER BY sent_at ASC`,
      [userId1, userId2, userId2, userId1]
    );
    rows.forEach(row => {
      row.content = decrypt(row.content);
    });
    return rows;
  }

  static async markAsRead(senderId, receiverId) {
    await db.execute(
      'UPDATE messages SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0',
      [senderId, receiverId]
    );
  }

  static async getUnreadCounts(userId) {
    const [rows] = await db.execute(
      `SELECT sender_id, COUNT(*) as unread
      FROM messages
      WHERE receiver_id = ? AND is_read = 0
      GROUP BY sender_id`,
      [userId]
    );
    return rows;
  }
}

module.exports = MessageModel;

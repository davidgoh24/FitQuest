const db = require('../config/db');

class AvatarModel {
  static async findById(avatarId) {
    const [rows] = await db.execute(
      'SELECT * FROM avatars WHERE id = ?',
      [avatarId]
    );
    return rows[0] || null;
  }

  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM avatars');
    return rows;
  }

  static async updateAvatar(userId, avatarId) {
    const [result] = await db.execute(
      'UPDATE users SET avatar_id = ? WHERE id = ?',
      [avatarId, userId]
    );
    return result;
  }
}

module.exports = AvatarModel;

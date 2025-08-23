const db = require('../config/db');

class BackgroundModel {
  static async findById(id) {
    const [rows] = await db.execute('SELECT * FROM backgrounds WHERE id = ?', [id]);
    return rows[0] || null;
  }

  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM backgrounds');
    return rows;
  }

  static async updateBackground(userId, backgroundId) {
    const [result] = await db.execute(
      'UPDATE users SET background_id = ? WHERE id = ?',
      [backgroundId, userId]
    );
    return result;
  }
}

module.exports = BackgroundModel;

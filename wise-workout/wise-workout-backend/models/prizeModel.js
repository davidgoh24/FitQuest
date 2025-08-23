const db = require('../config/db');

class PrizeModel {
  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM prizes');
    return rows;
  }

  static async findById(prizeId) {
    const [rows] = await db.execute(
      'SELECT * FROM prizes WHERE id = ?',
      [prizeId]
    );
    return rows[0] || null;
  }
}

module.exports = PrizeModel;

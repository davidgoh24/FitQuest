// models/LevelModel.js
const db = require('../config/db');

class LevelModel {
  static async getLevelByXP(xp) {
    const [rows] = await db.execute(
      'SELECT * FROM levels WHERE xp_required <= ? ORDER BY level DESC LIMIT 1',
      [xp]
    );
    return rows[0];
  }

  static async getNextLevel(currentLevel) {
    const [rows] = await db.execute(
      'SELECT * FROM levels WHERE level = ?',
      [currentLevel + 1]
    );
    return rows[0] || null;
  }

  static async getLevel(level) {
    const [rows] = await db.execute(
      'SELECT * FROM levels WHERE level = ?',
      [level]
    );
    return rows[0] || null;
  }
}

module.exports = LevelModel;

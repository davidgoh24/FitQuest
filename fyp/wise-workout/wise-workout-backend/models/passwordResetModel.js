const db = require('../config/db');

class PasswordResetModel {
  static async create(email, token, expiresAt) {
    await db.execute(
      'INSERT INTO password_resets (email, token, expires_at, failed_attempts) VALUES (?, ?, ?, 0)',
      [email, token, expiresAt]
    );
  }

  static async findByEmail(email) {
    const [rows] = await db.execute(
      'SELECT * FROM password_resets WHERE email = ?',
      [email]
    );
    return rows[0] || null;
  }

  static async findValidToken(email, token) {
    const [rows] = await db.execute(
      'SELECT * FROM password_resets WHERE email = ? AND token = ? AND expires_at > NOW()',
      [email, token]
    );
    return rows[0] || null;
  }

  static async incrementFailedAttempts(email) {
    await db.execute(
      'UPDATE password_resets SET failed_attempts = failed_attempts + 1 WHERE email = ?',
      [email]
    );
  }

  static async resetFailedAttempts(email) {
    await db.execute(
      'UPDATE password_resets SET failed_attempts = 0 WHERE email = ?',
      [email]
    );
  }

  static async deleteByEmail(email) {
    await db.execute('DELETE FROM password_resets WHERE email = ?', [email]);
  }
}

module.exports = PasswordResetModel;

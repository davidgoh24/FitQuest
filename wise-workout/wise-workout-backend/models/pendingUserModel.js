const db = require('../config/db');

class PendingUserModel {
  static async create(email, username = null, hashedPassword, otp, expiresAt, firstName, lastName) {
    if (!username) {
      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      username = `user${randomSuffix}`;
    }

    await db.execute(
      'DELETE FROM pending_users WHERE email = ? OR username = ?',
      [email, username]
    );

    const [result] = await db.execute(
      `INSERT INTO pending_users (email, username, password, otp, expires_at, failed_attempts, firstName, lastName)
       VALUES (?, ?, ?, ?, ?, 0, ?, ?)`,
      [email, username, hashedPassword, otp, expiresAt, firstName, lastName]
    );

    return result;
  }

  static async findByEmail(email) {
    const [rows] = await db.execute(
      'SELECT * FROM pending_users WHERE email = ?',
      [email]
    );
    return rows[0] || null;
  }

  static async verifyOTP(email, code) {
    const [rows] = await db.execute(
      `SELECT * FROM pending_users
       WHERE email = ? AND otp = ? AND expires_at > NOW()`,
      [email, code]
    );
    return rows[0] || null;
  }

  static async incrementFailedAttempts(email) {
    await db.execute(
      'UPDATE pending_users SET failed_attempts = failed_attempts + 1 WHERE email = ?',
      [email]
    );
  }

  static async resetFailedAttempts(email) {
    await db.execute(
      'UPDATE pending_users SET failed_attempts = 0 WHERE email = ?',
      [email]
    );
  }

  static async deleteByEmail(email) {
    await db.execute(
      'DELETE FROM pending_users WHERE email = ?',
      [email]
    );
  }
}

module.exports = PendingUserModel;

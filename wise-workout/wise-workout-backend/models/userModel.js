const db = require('../config/db');
const bcrypt = require('bcryptjs');
const PEPPER = require('../config/auth');

class UserModel {
  static async create(email, username = null, password = null, method = 'database', firstName = '', lastName = '', skipHash = false) {
    let hashedPassword = null;
    if (method === 'database' && password) {
        hashedPassword = skipHash ? password : await bcrypt.hash(password, 12);
    }
    if (!username) {
        const randomSuffix = Math.floor(1000 + Math.random() * 9000);
        username = `user${randomSuffix}`;
    }
    const [result] = await db.execute(
        `INSERT INTO users (email, username, password, method, firstName, lastName) VALUES (?, ?, ?, ?, ?, ?)`,
        [email, username, hashedPassword, method, firstName, lastName]
    );
    return result;
  }

  static async findById(userId) {
    const [rows] = await db.execute(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );
    return rows[0] || null;
  }

  static async findByEmail(email) {
    const [rows] = await db.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return rows[0] || null;
  }

  static async findByUsername(username) {
    const [rows] = await db.execute(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );
    return rows[0] || null;
  }

  static async verifyLogin(email, password) {
    const [rows] = await db.execute(
      'SELECT * FROM users WHERE email = ? AND method = "database"',
      [email]
    );

    const user = rows[0];
    if (!user || !user.password) return null;

    const isMatch = await bcrypt.compare(PEPPER+password, user.password);
    return isMatch ? user : null;
  }

  static async getTokenCount(userId) {
    const [rows] = await db.execute(
      'SELECT tokens FROM users WHERE id = ?',
      [userId]
    );
    return rows[0]?.tokens ?? 0;
  }

  static async updateDOB(userId, dob) {
    const [result] = await db.execute(
      'UPDATE users SET dob = ? WHERE id = ?',
      [dob, userId]
    );
    return result;
  }

  static async updateProfile(userId, updates) {
    const fields = [];
    const values = [];

    if (updates.username) {
      fields.push('username = ?');
      values.push(updates.username);
    }
    if (updates.firstName) {
      fields.push('firstName = ?');
      values.push(updates.firstName);
    }
    if (updates.lastName) {
      fields.push('lastName = ?');
      values.push(updates.lastName);
    }
    if (updates.dob) {
      fields.push('dob = ?');
      values.push(updates.dob);
    }

    if (fields.length === 0) return;

    values.push(userId);

    const sql = `UPDATE users SET ${fields.join(', ')} WHERE id = ?`;
    await db.execute(sql, values);
  }
  static async updatePasswordByEmail(email, hashedPassword) {
    await db.execute(
      'UPDATE users SET password = ? WHERE email = ? AND method = "database"',
      [hashedPassword, email]
    );
  }
  static async searchUsersWithStatus(query, userId) {
    let sql = `
      SELECT u.id, u.username, u.email, u.firstName, u.lastName,
        a.image_url as avatar_url,
        b.image_url as background_url,
        CASE
          WHEN f1.status = 'accepted' OR f2.status = 'accepted' THEN 'friends'
          WHEN f1.status = 'pending' THEN 'sent'        -- You sent them a request
          WHEN f2.status = 'pending' THEN 'pending'     -- They sent you a request
          ELSE 'none'
        END as relationship_status
      FROM users u
      LEFT JOIN friends f1
        ON f1.user_id = ? AND f1.friend_id = u.id
      LEFT JOIN friends f2
        ON f2.user_id = u.id AND f2.friend_id = ?
      LEFT JOIN avatars a ON u.avatar_id = a.id
      LEFT JOIN backgrounds b ON u.background_id = b.id
      WHERE (u.username LIKE ? OR u.email LIKE ?)
        AND u.id != ?
      LIMIT 20
    `;
    const values = [userId, userId, `%${query}%`, `%${query}%`, userId];
    const [rows] = await db.execute(sql, values);
    return rows;
  }
  static async addTokens(userId, amount) {
    await db.execute(
      'UPDATE users SET tokens = tokens + ? WHERE id = ?',
      [amount, userId]
    );
  }
  
  static async getPremiumUntil(userId) {
    const [rows] = await db.execute(
      'SELECT premium_until FROM users WHERE id = ?',
      [userId]
    );
    return rows[0]?.premium_until ? new Date(rows[0].premium_until) : null;
  }  
  static async deductTokens(userId, amount) {
    const [result] = await db.execute(
      'UPDATE users SET tokens = tokens - ? WHERE id = ? AND tokens >= ?',
      [amount, userId, amount]
    );
    return result.affectedRows > 0;
  }


  static async addXP(userId, amount) {
    await db.execute('UPDATE users SET xp = xp + ? WHERE id = ?', [amount, userId]);
  }
  static async getLevelsLeaderboard(limit = 20) {
    const sql = `
      SELECT u.id, u.username, u.firstName, u.lastName, u.avatar_id, u.tokens, u.xp,
        (
          SELECT MAX(l.level)
          FROM levels l
          WHERE l.xp_required <= u.xp
        ) as level,
        a.image_url as avatar_url,
        b.image_url as background_url
      FROM users u
      LEFT JOIN avatars a ON u.avatar_id = a.id
      LEFT JOIN backgrounds b ON u.background_id = b.id
      WHERE u.isSuspended = false
      ORDER BY level DESC, u.xp DESC, u.id ASC
      LIMIT ${limit}`;
    const [rows] = await db.execute(sql);
    return rows;
  }
  static async getLoginStreakAndDate(userId) {
    const [rows] = await db.execute('SELECT last_login, login_streak FROM users WHERE id = ?', [userId]);
    return rows[0];
  }

  static async updateLoginStreak(userId, lastLogin, loginStreak) {
    await db.execute(
      'UPDATE users SET last_login = ?, login_streak = ? WHERE id = ?',
      [lastLogin, loginStreak, userId]
    );
  }
  static async setPremium(userId, premiumUntil) {
    await db.execute(
      'UPDATE users SET role = "premium", premium_until = ? WHERE id = ?',
      [premiumUntil, userId]
    );
  }

  static async downgradeToUserIfExpired(userId) {
    const [rows] = await db.execute(
      'SELECT role, premium_until FROM users WHERE id = ?',
      [userId]
    );
    const user = rows[0];
    if (user && user.role === 'premium' && (!user.premium_until || new Date(user.premium_until) < new Date())) {
      await db.execute('UPDATE users SET role = "user" WHERE id = ?', [userId]);
    }
  }
  static async updateLanguage(userId, language) {
    const [result] = await db.execute(
      `UPDATE users SET language = ? WHERE id = ?`,
      [language, userId]
    );
    return result;
  }
  
  static async getLanguage(userId) {
    const [rows] = await db.execute(
      `SELECT language FROM users WHERE id = ? LIMIT 1`,
      [userId]
    );
    return rows[0]?.language || 'en';
  }
  static async updatePasswordById(userId, hashedPassword) {
    await db.execute(
      'UPDATE users SET password = ? WHERE id = ? AND method = "database"',
      [hashedPassword, userId]
    );
  }
  
}

module.exports = UserModel;

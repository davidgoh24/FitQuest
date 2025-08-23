const db = require('../config/db');

const ReminderModel = {
  async findByUser(userId) {
    const [rows] = await db.execute(
      'SELECT * FROM reminders WHERE user_id = ? LIMIT 1',
      [userId]
    );
    return rows[0];
  },

  async insert(userId, { title, message, time, daysOfWeek }) {
    await db.execute(
      `REPLACE INTO reminders (user_id, title, message, time, days_of_week)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, title, message, time, daysOfWeek]
    );
    return this.findByUser(userId);
  },

  async deleteByUser(userId) {
    await db.execute('DELETE FROM reminders WHERE user_id = ?', [userId]);
  },
};

module.exports = ReminderModel;

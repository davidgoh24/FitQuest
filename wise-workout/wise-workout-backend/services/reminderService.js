const ReminderModel = require('../models/reminderModel');

class ReminderService {
  static async getReminder(userId) {
    return await ReminderModel.findByUser(userId);
  }

  static async setReminder(userId, data) {
    return await ReminderModel.insert(userId, data);
  }

  static async clearReminder(userId) {
    return await ReminderModel.deleteByUser(userId);
  }
}

module.exports = ReminderService;

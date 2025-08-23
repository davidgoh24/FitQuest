const ReminderService = require('../services/reminderService');

class ReminderController {
  static async getReminder(req, res) {
    try {
      const reminder = await ReminderService.getReminder(req.user.id);
      res.json(reminder || {});
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }

  static async setReminder(req, res) {
    try {
      const { title, message, time, daysOfWeek } = req.body;
      const reminder = await ReminderService.setReminder(req.user.id, {
        title,
        message,
        time,
        daysOfWeek,
      });
      res.status(201).json(reminder);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }

  static async clearReminder(req, res) {
    try {
        console.log('tes');
      await ReminderService.clearReminder(req.user.id);
      res.json({ success: true });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
}

module.exports = ReminderController;

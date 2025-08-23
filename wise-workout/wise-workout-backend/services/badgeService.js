const BadgeModel = require('../models/badgeModel');

class BadgeService {
  static async getAllBadges() {
    return BadgeModel.getAllBadges();
  }

  static async getUserBadges(userId) {
    return BadgeModel.getUserBadges(userId);
  }

  static async grantBadge(userId, badgeId) {
    return BadgeModel.grantBadge(userId, badgeId);
  }
}

module.exports = BadgeService;

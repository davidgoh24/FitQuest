const SubscriptionHistoryModel = require('../models/subscriptionHistoryModel');

class SubscriptionHistoryService {
  static async getAll(plan, search) {
    return await SubscriptionHistoryModel.findAllWithUser({ plan, search });
  }

  static async getByUserId(userId) {
    return await SubscriptionHistoryModel.findByUserId(userId);
  }
}

module.exports = SubscriptionHistoryService;

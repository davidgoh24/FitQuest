const FeedbackModel = require('../models/feedbackModel');

class FeedbackService {
  static async addFeedback(userId, feedbackData) {
    await FeedbackModel.addFeedback(userId, feedbackData);
  }

  static async getPublishedFeedback() {
    return await FeedbackModel.getPublishedFeedback();
  }
}

module.exports = FeedbackService;

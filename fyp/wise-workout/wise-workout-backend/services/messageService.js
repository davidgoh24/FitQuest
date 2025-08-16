const MessageModel = require('../models/messageModel');
const DailyQuestModel = require('../models/dailyQuestModel');

class MessageService {
  static async sendMessage(senderId, receiverId, content) {
    const result = await MessageModel.sendMessage(senderId, receiverId, content);

    const today = new Date().toISOString().slice(0,10);
    await DailyQuestModel.markQuestDone(senderId, 'MESSAGE_FRIEND', today);

    return result;
  }

  static async getConversation(userId1, userId2) {
    return await MessageModel.getConversation(userId1, userId2);
  }
  static async markAsRead(senderId, receiverId) {
    await MessageModel.markAsRead(senderId, receiverId);
  }

  static async getUnreadCounts(userId) {
    return await MessageModel.getUnreadCounts(userId);
  }
}

module.exports = MessageService;

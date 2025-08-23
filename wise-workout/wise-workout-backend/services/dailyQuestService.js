const DailyQuestModel = require('../models/dailyQuestModel');
const UserService = require('./userService');

class DailyQuestService {
  static async ensureTodayQuests(userId) {
    const quests = await DailyQuestModel.getQuests();
    const today = new Date().toISOString().slice(0,10);
    for (const quest of quests) {
      await DailyQuestModel.insertUserDailyQuest(userId, quest.code, today);
    }
  }

  static async getTodayQuests(userId) {
    const today = new Date().toISOString().slice(0,10);
    return await DailyQuestModel.getUserDailyQuests(userId, today);
  }

  static async claimQuest(userId, questCode) {
    const today = new Date().toISOString().slice(0,10);
    const quest = await DailyQuestModel.getQuestRow(userId, questCode, today);
    if (!quest) throw new Error('QUEST_NOT_FOUND');
    if (!quest.done) throw new Error('QUEST_NOT_DONE');
    if (quest.claimed) throw new Error('QUEST_ALREADY_CLAIMED');

    await DailyQuestModel.markQuestClaimed(userId, questCode, today);
    await UserService.addXPAndCheckLevel(userId, quest.xp_reward);
  }

  static async claimAllQuests(userId) {
    const today = new Date().toISOString().slice(0,10);
    const quests = await DailyQuestModel.getDoneUnclaimed(userId, today);
    let total = 0;
    for (const quest of quests) {
      await DailyQuestModel.markQuestClaimed(userId, quest.quest_code, today);
      await UserService.addXPAndCheckLevel(userId, quest.xp_reward);
      total += quest.xp_reward;
    }
    return total;
  }
}

module.exports = DailyQuestService;

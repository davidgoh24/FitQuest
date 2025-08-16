const DailyQuestService = require('../services/dailyQuestService');

exports.getDailyQuests = async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const quests = await DailyQuestService.getTodayQuests(userId);
    res.json(quests);
  } catch (err) {
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

exports.claimQuest = async (req, res) => {
  const userId = req.user?.id;
  const { questCode } = req.body;
  if (!userId || !questCode) return res.status(400).json({ message: 'Missing data' });

  try {
    await DailyQuestService.claimQuest(userId, questCode);
    res.json({ message: 'Quest claimed' });
  } catch (err) {
    res.status(400).json({ message: err.message || 'Error claiming quest' });
  }
};

exports.claimAllQuests = async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const total = await DailyQuestService.claimAllQuests(userId);
    res.json({ message: 'All quests claimed', totalXP: total });
  } catch (err) {
    res.status(400).json({ message: err.message || 'Error claiming quests' });
  }
};

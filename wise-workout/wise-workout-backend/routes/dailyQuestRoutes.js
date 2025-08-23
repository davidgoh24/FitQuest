const express = require('express');
const router = express.Router();
const dailyQuestController = require('../controllers/dailyQuestController');

router.get('/daily-quests', dailyQuestController.getDailyQuests);
router.post('/claim-quest', dailyQuestController.claimQuest);
router.post('/claim-all-quests', dailyQuestController.claimAllQuests);

module.exports = router;
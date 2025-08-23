const express = require('express');
const router = express.Router();
const badgeController = require('../controllers/badgeController');

router.get('/all', badgeController.getAllBadges);
router.get('/mine', badgeController.getUserBadges);
router.post('/grant', badgeController.grantBadge);

module.exports = router;

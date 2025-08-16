const express = require('express');
const router = express.Router();
const subscriptionHistoryController = require('../controllers/subscriptionHistoryController');

router.get('/admin/subscriptions', subscriptionHistoryController.getAll);
router.get('/admin/subscriptions/:userId', subscriptionHistoryController.getByUserId);

module.exports = router;

const express = require('express');
const router = express.Router();
const { sendMessage, getConversation, markAsRead, getUnreadCounts } = require('../controllers/messageController');

router.post('/send', sendMessage);
router.get('/conversation/:userId', getConversation);
router.post('/mark-as-read', markAsRead);
router.get('/unread-counts', getUnreadCounts);

module.exports = router;

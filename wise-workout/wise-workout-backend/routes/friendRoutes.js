const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friendController');

router.post('/send', friendController.sendRequest);
router.post('/accept', friendController.acceptRequest);
router.get('/premium', friendController.getPremiumFriends);
router.post('/reject', friendController.rejectRequest);
router.get('/list', friendController.getFriends);
router.get('/pending', friendController.getPendingRequests);
router.get('/sent', friendController.getSentRequests);
router.get('/search', friendController.searchUsers);

module.exports = router;

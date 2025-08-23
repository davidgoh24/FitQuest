const express = require('express');
const router = express.Router();
const reminderController = require('../controllers/reminderController');


router.get('/', reminderController.getReminder);
router.post('/', reminderController.setReminder);
router.delete('/', reminderController.clearReminder);

module.exports = router;

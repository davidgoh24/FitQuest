const express = require('express');
const router = express.Router();
const userPreferencesController = require('../controllers/userPreferencesController');

router.get('/', userPreferencesController.getUserPreferences);
router.post('/submit', userPreferencesController.submitUserPreferences);
router.get('/check', userPreferencesController.checkPreferences);
router.put('/update', userPreferencesController.updatePreferences);

module.exports = router;

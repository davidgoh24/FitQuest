const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authenticateUser = require('../middlewares/authMiddleware');

router.post('/login', authController.login);
router.get('/me', authenticateUser, authController.me);

module.exports = router;

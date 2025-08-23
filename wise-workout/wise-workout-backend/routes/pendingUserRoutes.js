const express = require('express');
const router = express.Router();
const { verifyOtpRegister } = require('../controllers/pendingUserController');

router.post('/verify-otp-register', verifyOtpRegister);

module.exports = router;

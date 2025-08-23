const express = require('express');
const router = express.Router();
const {
  login,
  loginGoogle,
  loginApple,
  loginFacebook,
  register,
  me
} = require('../controllers/authController');
const authenticateUser = require('../middlewares/authMiddleware');

const {
  requestPasswordReset,
  verifyPasswordReset
} = require('../controllers/passwordResetController');

router.post('/login', login);
router.post('/google', loginGoogle);
router.post('/apple', loginApple);
router.post('/facebook', loginFacebook);
router.post('/register', register);
router.post('/forgot-password', requestPasswordReset);
router.post('/verify-password-reset', verifyPasswordReset);
router.get('/me', authenticateUser, me);

module.exports = router;

const { isValidEmail } = require('../utils/sanitize');
const { setCookie } = require('../utils/cookieAuth');
const PendingUserService = require('../services/pendingUserService');

exports.verifyOtpRegister = async (req, res) => {
  const email = isValidEmail(req.body.email);
  const code = req.body.code?.trim();

  if (!email || !code) {
    return res.status(400).json({ message: 'Invalid email or code' });
  }

  try {
    await PendingUserService.verifyOtpAndRegister(email, code);
    await setCookie(res, email);
    res.status(201).json({ message: 'Registration and verification successful' });
  } catch (err) {
    if (err.message === 'INVALID_OTP') {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }
    if (err.message === 'USER_EXISTS') {
      return res.status(409).json({ message: 'User already exists' });
    }
    if (err.message === 'OTP_MAX_ATTEMPTS') {
      return res.status(429).json({ message: 'Too many failed attempts. Please request a new OTP.' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

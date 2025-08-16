const PasswordResetService = require('../services/passwordResetService');

exports.requestPasswordReset = async (req, res) => {
  const email = req.body.email?.trim();
  if (!email) return res.status(400).json({ message: 'Email is required' });
  try {
    await PasswordResetService.requestReset(email);
    res.json({ message: 'OTP sent to your email' });
  } catch (err) {
    if (err.message === 'EMAIL_NOT_FOUND') {
      return res.status(404).json({ message: 'Email not found' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

exports.verifyPasswordReset = async (req, res) => {
  const email = req.body.email?.trim();
  const otp = req.body.otp?.trim();
  const newPassword = req.body.newPassword?.trim();

  if (!email || !otp || !newPassword) {
    return res.status(400).json({ message: 'Missing email, OTP, or password' });
  }
  try {
    await PasswordResetService.verifyReset(email, otp, newPassword);
    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    if (err.message === 'INVALID_OR_EXPIRED_OTP') {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }
    if (err.message === 'OTP_MAX_ATTEMPTS') {
      return res.status(429).json({ message: 'Too many failed attempts. Please request a new OTP.' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

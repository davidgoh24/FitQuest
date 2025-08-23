const bcrypt = require('bcryptjs');
const { generateOTP, getExpiry } = require('../utils/otp');
const { sendOTPToEmail } = require('../utils/otpService');
const PasswordResetModel = require('../models/passwordResetModel');
const UserModel = require('../models/userModel');
const PEPPER = require('../config/auth');

const MAX_ATTEMPTS = 5;

class PasswordResetService {
  static async requestReset(email) {
    const user = await UserModel.findByEmail(email);
    if (!user) throw new Error('EMAIL_NOT_FOUND');

    const otp = generateOTP();
    const expiresAt = getExpiry();

    await PasswordResetModel.deleteByEmail(email);
    await PasswordResetModel.create(email, otp, expiresAt);
    await sendOTPToEmail(email, otp);
  }

  static async verifyReset(email, otp, newPassword) {
    const record = await PasswordResetModel.findByEmail(email);
    if (!record || record.failed_attempts >= MAX_ATTEMPTS) {
      throw new Error('OTP_MAX_ATTEMPTS');
    }

    const validRecord = await PasswordResetModel.findValidToken(email, otp);
    if (!validRecord) {
      await PasswordResetModel.incrementFailedAttempts(email);
      throw new Error('INVALID_OR_EXPIRED_OTP');
    }

    const hashed = await bcrypt.hash(PEPPER+newPassword, 12);
    await UserModel.updatePasswordByEmail(email, hashed);
    await PasswordResetModel.resetFailedAttempts(email);
    await PasswordResetModel.deleteByEmail(email);
  }
}

module.exports = PasswordResetService;

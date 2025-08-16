const UserModel = require('../models/userModel');
const PendingUserModel = require('../models/pendingUserModel');

const MAX_ATTEMPTS = 5;

class PendingUserService {
  static async verifyOtpAndRegister(email, code) {
    const pendingUser = await PendingUserModel.findByEmail(email);
    if (!pendingUser || pendingUser.failed_attempts >= MAX_ATTEMPTS) {
      throw new Error('OTP_MAX_ATTEMPTS');
    }

    if (
      pendingUser.otp !== code ||
      new Date(pendingUser.expires_at) < new Date()
    ) {
      await PendingUserModel.incrementFailedAttempts(email);
      throw new Error('INVALID_OTP');
    }

    const existingUser = await UserModel.findByEmail(email);
    if (existingUser) {
      await PendingUserModel.deleteByEmail(email);
      throw new Error('USER_EXISTS');
    }

    await UserModel.create(
      email,
      pendingUser.username,
      pendingUser.password,
      'database',
      pendingUser.firstName,
      pendingUser.lastName,
      true
    );

    await PendingUserModel.resetFailedAttempts(email);
    await PendingUserModel.deleteByEmail(email);
  }
}

module.exports = PendingUserService;

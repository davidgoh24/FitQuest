const UserModel = require('../models/userModel');
const PendingUserModel = require('../models/pendingUserModel');
const bcrypt = require('bcryptjs');
const { generateOTP, getExpiry } = require('../utils/otp');
const PEPPER = require('../config/auth');

class AuthService {
  static async loginWithCredentials(email, password) {
    return await UserModel.verifyLogin(email, password);
  }

  static async loginWithOAuth(email, firstName, lastName, method) {
    let user = await UserModel.findByEmail(email);
    if (!user) {
      await UserModel.create(email, null, null, method, firstName, lastName);
    }
    return user || { email };
  }

  static async registerUser(email, username, password, firstName, lastName) {
    const existingUser = await UserModel.findByEmail(email);
    if (existingUser) throw new Error('EMAIL_EXISTS');

    const existingUsername = await UserModel.findByUsername(username);
    if (existingUsername) throw new Error('USERNAME_EXISTS');

    const hashedPassword = await bcrypt.hash(PEPPER+password, 12);
    const otp = generateOTP();
    const expiresAt = getExpiry();

    await PendingUserModel.create(email, username, hashedPassword, otp, expiresAt, firstName, lastName);
    return otp;
  }
}

module.exports = AuthService;

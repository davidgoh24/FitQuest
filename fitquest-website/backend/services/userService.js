const UserModel = require('../models/userModel');

class UserService {
  static async getDashboardStats() {
    const [total, active, premium] = await Promise.all([
      UserModel.getTotalUserCount(),
      UserModel.getActiveUserCount(),
      UserModel.getPremiumUserCount()
    ]);
    return { total, active, premium };
  }
  
  static async getAllUsers() {
    return await UserModel.findAllWithPreferences();
  }

  static async getPremiumUsers() {
  return await UserModel.findPremiumUsers();
  }

  static async suspendUser(userId) {
    await UserModel.suspendUser(userId);
  }

  static async unsuspendUser(userId) {
    await UserModel.unsuspendUser(userId);
  }
}

module.exports = UserService;

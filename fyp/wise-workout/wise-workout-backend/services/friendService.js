const FriendModel = require('../models/friendModel');
const UserModel = require('../models/userModel');
const BadgeService = require('../services/badgeService');

class FriendService {
  static async sendRequest(userId, friendId) {
    return await FriendModel.sendRequest(userId, friendId);
  }
  static async acceptRequest(userId, friendId) {
    await FriendModel.acceptRequest(userId, friendId);

    // Grant badge to the user if it's their first friend
    const userFriends = await FriendModel.getFriends(userId);
    if (userFriends.length === 1) {
      await BadgeService.grantBadge(userId, 6);
    }

    // Grant badge to the friend if it's their first friend
    const friendFriends = await FriendModel.getFriends(friendId);
    if (friendFriends.length === 1) {
      await BadgeService.grantBadge(friendId, 6);
    }
  }

  static async rejectRequest(userId, friendId) {
    await FriendModel.rejectRequest(userId, friendId);
  }

  static async getFriends(userId) {
    return await FriendModel.getFriends(userId);
  }

  static async getPendingRequests(userId) {
    return await FriendModel.getPendingRequests(userId);
  }

  static async getSentRequests(userId) {
    return await FriendModel.getSentRequests(userId);
  }

  static async searchUsers(userId, query) {
    return await UserModel.searchUsersWithStatus(query, userId);
  }

  static async getPremiumFriends(userId) {
    return await FriendModel.getPremiumFriends(userId);
  }
}

module.exports = FriendService;

const UserModel = require('../models/userModel');
const AvatarModel = require('../models/avatarModel');
const BackgroundModel = require('../models/backgroundModel');
const LevelModel = require('../models/levelModel');
const BadgeService = require('./badgeService');
const premiumCosts = require('../config/premiumCosts');
const SubscriptionHistoryModel = require('../models/subscriptionHistoryModel');
const UserXpDailyModel = require('../models/userXpDailyModel');
const bcrypt = require('bcryptjs');
const PEPPER = require('../config/auth');

class UserService {
  static async setAvatar(userId, avatarId) {
    if (!userId || !avatarId) throw new Error('MISSING_DATA');
    const avatar = await AvatarModel.findById(avatarId);
    if (!avatar) throw new Error('AVATAR_NOT_FOUND');
    const user = await UserModel.findById(userId);
    if (avatar.is_premium && user.role !== 'premium') {
      throw new Error('PREMIUM_REQUIRED');
    }
    await AvatarModel.updateAvatar(userId, avatarId);
  }

  static async setBackground(userId, backgroundId) {
    if (!userId || !backgroundId) throw new Error('MISSING_DATA');
    const background = await BackgroundModel.findById(backgroundId);
    if (!background) throw new Error('BACKGROUND_NOT_FOUND');
    const user = await UserModel.findById(userId);
    if (background.is_premium && user.role !== 'premium') {
      throw new Error('PREMIUM_REQUIRED');
    }
    await BackgroundModel.updateBackground(userId, backgroundId);
  }

  static async getCurrentAvatar(userId) {
    const user = await UserModel.findById(userId);
    if (!user || !user.avatar_id) throw new Error('NO_AVATAR');
    const avatar = await AvatarModel.findById(user.avatar_id);
    if (!avatar) throw new Error('AVATAR_DATA_MISSING');
    return avatar;
  }

  static async getCurrentBackground(userId) {
    const user = await UserModel.findById(userId);
    if (!user || !user.background_id) throw new Error('NO_BACKGROUND');
    const background = await BackgroundModel.findById(user.background_id);
    if (!background) throw new Error('BACKGROUND_DATA_MISSING');
    return background;
  }

  static async getCurrentProfile(userId) {
    const user = await UserModel.findById(userId);
    if (!user) throw new Error('USER_NOT_FOUND');
    const avatar = user.avatar_id ? await AvatarModel.findById(user.avatar_id) : null;
    const background = user.background_id ? await BackgroundModel.findById(user.background_id) : null;
    const levelObj = await LevelModel.getLevelByXP(user.xp);
    const nextLevelObj = await LevelModel.getLevel(levelObj.level + 1);
    const progressInLevel = user.xp - levelObj.xp_required;
    const xpForThisLevel = (nextLevelObj?.xp_required || user.xp) - levelObj.xp_required;
    return {
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      dob: user.dob,
      role: user.role,
      tokens: user.tokens,
      avatar: avatar ? avatar.image_url : null,
      background: background ? background.image_url : null,
      level: levelObj.level,
      totalXP: user.xp,
      progressInLevel,
      xpForThisLevel
    };
  }

  static async addXPAndCheckLevel(userId, xpToAdd) {
    const user = await UserModel.findById(userId);
    const oldXP = user.xp || 0;
    const oldLevelObj = await LevelModel.getLevelByXP(oldXP);
    const oldLevel = oldLevelObj?.level || 1;
    await UserModel.addXP(userId, xpToAdd);
    const updatedUser = await UserModel.findById(userId);
    const newXP = updatedUser.xp;
    const newLevelObj = await LevelModel.getLevelByXP(newXP);
    const newLevel = newLevelObj?.level || 1;
    let rewardedTokens = 0;
    if (newLevel > oldLevel) {
      for (let lvl = oldLevel + 1; lvl <= newLevel; lvl++) {
        const lvlObj = await LevelModel.getLevel(lvl);
        rewardedTokens += lvlObj?.reward_tokens || 0;
      }
      if (rewardedTokens > 0) {
        await UserService.applyPrize(userId, { type: 'tokens', value: rewardedTokens });
      }
    }
    const nextLevelObj = await LevelModel.getLevel(newLevel + 1);
    const xpForThisLevel = (nextLevelObj?.xp_required || newXP) - newLevelObj.xp_required;
    const progressInLevel = newXP - newLevelObj.xp_required;
    return {
      totalXP: newXP,
      level: newLevel,
      progressInLevel,
      xpForThisLevel,
      rewardedTokens
    };
  }
  static async applyPrize(userId, prize) {
    if (prize.type === 'tokens') {
      await UserModel.addTokens(userId, prize.value);
    } else if (prize.type === 'trial') {
      let current = await UserModel.getPremiumUntil(userId);
      const now = new Date();
      if (!current || current < now) current = now;
      current.setDate(current.getDate() + prize.value);
      await UserModel.setPremium(userId, current);
    }
  }
  

  static async updateProfile(userId, updates) {
    if (updates.username) {
      const existing = await UserModel.findByUsername(updates.username);
      if (existing && existing.id !== userId) {
        throw new Error('USERNAME_EXISTS');
      }
    }
    await UserModel.updateProfile(userId, updates);
  }

  static async getLeaderboard(type = 'levels', limit = 20) {
    if (type === '') {
      throw new Error('');
    } else {
      return await UserModel.getLevelsLeaderboard(limit);
    }
  }

  static async updateLoginStreak(userId) {
    const user = await UserModel.getLoginStreakAndDate(userId);
    const today = new Date().toISOString().slice(0, 10);
    const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    let streak = 1;
    if (user.last_login === today) return user.login_streak;
    if (user.last_login === yesterday) streak = user.login_streak + 1;
    await UserModel.updateLoginStreak(userId, today, streak);
    if (streak === 7) await BadgeService.grantBadge(userId, 2);
    if (streak === 30) await BadgeService.grantBadge(userId, 12);
    return streak;
  }

  static async buyPremium(userId, plan, method = "money") {
    if (!plan || !premiumCosts[plan]) throw new Error('INVALID_PLAN');
    if (!['money', 'tokens'].includes(method)) throw new Error('INVALID_METHOD');
    
    const { tokens: tokenCost, durationDays, price } = premiumCosts[plan];
    const user = await UserModel.findById(userId);
    const purchaseDate = new Date();

    if (method === 'tokens') {
        if (tokenCost == null) throw new Error('PLAN_NOT_BUYABLE_WITH_TOKENS');
        if ((user.tokens ?? 0) < tokenCost) throw new Error('NOT_ENOUGH_TOKENS');
        const success = await UserModel.deductTokens(userId, tokenCost);
        if (!success) throw new Error('FAILED_TO_DEDUCT_TOKENS');
    }
    let current = user.premium_until ? new Date(user.premium_until) : purchaseDate;
    if (current < purchaseDate) current = purchaseDate;
    let newExpiry;
    if (durationDays >= 36500) {
        newExpiry = new Date('2099-12-31T23:59:59Z');
    } else {
        current.setDate(current.getDate() + durationDays);
        newExpiry = current;
    }

    await UserModel.setPremium(userId, newExpiry);
    await BadgeService.grantBadge(userId, 8);

    // Expiry from THIS purchase only (does not include leftover premium time), so this does not count stacking
    let purchaseExpiry;
    if (durationDays >= 36500) {
        purchaseExpiry = new Date('2099-12-31T23:59:59Z');
    } else {
        purchaseExpiry = new Date(purchaseDate);
        purchaseExpiry.setDate(purchaseExpiry.getDate() + durationDays);
    }

    await SubscriptionHistoryModel.insert({
        userId,
        plan,
        method,
        amount: method === 'money' ? price : null,
        tokensUsed: method === 'tokens' ? tokenCost : null,
        startDate: purchaseDate,
        endDate: purchaseExpiry
    });

    return newExpiry;
  }

  static async checkAndDowngradePremium(userId) {
    await UserModel.downgradeToUserIfExpired(userId);
  }

  static async getDailyXP(userId, date) {
    return await UserXpDailyModel.getDailyXP(userId, date);
  }
  static async setLanguage(userId, language) {
    return await UserModel.updateLanguage(userId, language);
  }
  
  static async getLanguage(userId) {
    return await UserModel.getLanguage(userId);
  }  
  static async changePassword(userId, currentPassword, newPassword) {
    const user = await UserModel.findById(userId);
    if (!user || !user.password) throw new Error('USER_NOT_FOUND');
  
    const isMatch = await bcrypt.compare(PEPPER + currentPassword, user.password);
    if (!isMatch) throw new Error('INVALID_CURRENT_PASSWORD');
  
    const hashed = await bcrypt.hash(PEPPER + newPassword, 12);
    await UserModel.updatePasswordById(userId, hashed);
  }  

}

module.exports = UserService;

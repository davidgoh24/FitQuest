const db = require('../config/db');
const ChallengeModel = require('../models/challengeModel');
const ChallengeInvitesModel = require('../models/challengeInvitesModel');
const ChallengeProgressModel = require('../models/challengeProgressModel');
const UserModel = require('../models/userModel');
const UserService = require('./userService');

const ChallengeService = {
  getAllChallenges: async () => {
    return await ChallengeModel.getAllChallenges();
  },

  getInvitations: async (userId) => {
    return await ChallengeInvitesModel.getPendingInvites(userId);
  },

  getAcceptedChallenges: async (userId) => {
    return await ChallengeInvitesModel.getAcceptedChallenges(userId);
  },

  acceptChallenge: async (inviteId) => {
    const conn = await db.getConnection();
    try {
      await conn.beginTransaction();
      const invite = await ChallengeInvitesModel.getInviteForAcceptance(inviteId);
      if (!invite) throw new Error('Invite not found');
      const now = new Date();
      const baseValue = invite.custom_duration_value || invite.duration;
      const unit = (invite.custom_duration_unit || 'days').toLowerCase();
      let expiresAt;
      if (unit === 'months') {
        const d = new Date(now.getTime());
        d.setMonth(d.getMonth() + baseValue);
        expiresAt = d;
      } else if (unit === 'weeks') {
        expiresAt = new Date(now.getTime() + baseValue * 7 * 24 * 60 * 60 * 1000);
      } else {
        expiresAt = new Date(now.getTime() + baseValue * 24 * 60 * 60 * 1000);
      }
      await ChallengeInvitesModel.markInviteAccepted(inviteId, now, expiresAt);
      await ChallengeProgressModel.insertInitialProgress(inviteId, invite.receiver_id);
      await ChallengeProgressModel.insertInitialProgress(inviteId, invite.sender_id);
      await conn.commit();
    } catch (e) {
      await conn.rollback();
      throw e;
    } finally {
      conn.release();
    }
  },

  rejectChallenge: async (inviteId) => {
    return await ChallengeInvitesModel.markInviteRejected(inviteId);
  },

  sendChallenge: async ({ senderId, receiverId, title, customValue, customDurationValue, customDurationUnit }) => {
    const challengeId = await ChallengeModel.findChallengeIdByTitle(title);
    if (!challengeId) throw new Error('Challenge template not found');
    return await ChallengeInvitesModel.createChallengeInvite(
      challengeId,
      senderId,
      receiverId,
      customValue,
      customDurationValue,
      customDurationUnit
    );
  },

  getFriendsToChallenge: async (userId, title) => {
    return await ChallengeInvitesModel.getPremiumFriendsToChallenge(userId, title);
  },

  getLeaderboard: async (userId) => {
    return await ChallengeModel.getLeaderboardsByUser(userId);
  },

  checkAndCompleteChallenge: async (inviteId) => {
    const progressRows = await ChallengeInvitesModel.getInviteProgressAndUsers(inviteId);
    if (!progressRows.length) return;
  
    const target = progressRows[0].custom_value || progressRows[0].value;
    const winner = progressRows.find(p => p.progress_value >= target);
    if (!winner) return;
  
    const loser = progressRows.find(p => p.user_id !== winner.user_id);
  
    const winnerXP = 150, loserXP = 30;
    const winnerTokens = 100, loserTokens = 20;
  
    await ChallengeInvitesModel.markChallengeCompleted(inviteId);
  
    await UserModel.addXP(winner.user_id, winnerXP);
    await UserService.applyPrize(winner.user_id, { type: 'tokens', value: winnerTokens });
  
    if (loser) {
      await UserModel.addXP(loser.user_id, loserXP);
      await UserService.applyPrize(loser.user_id, { type: 'tokens', value: loserTokens });
    }
  }
};

module.exports = ChallengeService;

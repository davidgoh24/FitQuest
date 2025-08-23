// controllers/challengeController.js
const ChallengeService = require('../services/challengeService');

const ChallengeController = {
  getAllChallenges: async (req, res) => {
    try {
      const challenges = await ChallengeService.getAllChallenges();
      res.status(200).json(challenges);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching challenges', error: err.message });
    }
  },
  getInvitations: async (req, res) => {
    try {
      const userId = req.user.id;
      const invites = await ChallengeService.getInvitations(userId);
      res.status(200).json(invites);
    } catch (err) {
      console.error('Error fetching invitations:', err);
      res.status(500).json({ message: 'Error fetching invitations', error: err.message });
    }
  },

  // Get accepted challenges for the logged-in user
  getAcceptedChallenges: async (req, res) => {
    try {
      const userId = req.user.id;
      const challenges = await ChallengeService.getAcceptedChallenges(userId);
      res.status(200).json(challenges);
    } catch (err) {
      console.error('Error fetching accepted challenges:', err);
      res.status(500).json({ message: 'Error fetching accepted challenges', error: err.message });
    }
  },

  // Accept a challenge invite by ID
  acceptChallenge: async (req, res) => {
    try {
      const inviteId = req.params.id;
      await ChallengeService.acceptChallenge(inviteId);
      res.status(200).json({ message: 'Challenge accepted' });
    } catch (err) {
      console.error('Error accepting challenge:', err);
      res.status(500).json({ message: 'Error accepting challenge', error: err.message });
    }
  },

  // Reject a challenge invite by ID
  rejectChallenge: async (req, res) => {
    try {
      const inviteId = req.params.id;
      await ChallengeService.rejectChallenge(inviteId);
      res.status(200).json({ message: 'Challenge rejected' });
    } catch (err) {
      console.error('Error rejecting challenge:', err);
      res.status(500).json({ message: 'Error rejecting challenge', error: err.message });
    }
  },

  sendChallenge: async (req, res) => {
    try {
      const senderId = req.user.id;
      const { receiverId, title, customValue, customDurationValue, customDurationUnit } = req.body;
  

      if (!receiverId || !title || customValue == null) {
        return res.status(400).json({ message: 'Missing required fields' });
      }
  
      const challengeId = await ChallengeService.sendChallenge({
        senderId,
        receiverId,
        title,
        customValue,
        customDurationValue,
        customDurationUnit
      });
  
      res.status(200).json({ message: 'Challenge sent', challengeId });
    } catch (err) {
      console.error('Error sending challenge:', err);
      res.status(500).json({ message: 'Error sending challenge', error: err.message });
    }
  },  
  getFriendsToChallenge: async (req, res) => {
    try {
      const userId = req.user.id;
      const { title } = req.query;
      if (!title) return res.status(400).json({ message: 'Missing challenge title' });
      const friends = await ChallengeService.getFriendsToChallenge(userId, title);
      res.status(200).json(friends);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching friends to challenge', error: err.message });
    }
  },
  getLeaderboard: async (req, res) => {
    try {
      const userId = req.user.id;
      const leaderboard = await ChallengeService.getLeaderboard(userId); 
      res.status(200).json(leaderboard);
    } catch (err) {
      res.status(500).json({ message: 'Error fetching leaderboard', error: err.message });
    }
  }  
};

module.exports = ChallengeController;

const UserService = require('../services/userService');
const premiumCosts = require('../config/premiumCosts');

exports.setAvatar = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { avatarId } = req.body;

    await UserService.setAvatar(userId, avatarId);
    res.status(200).json({ message: 'Avatar updated successfully' });
  } catch (err) {
    const map = {
      MISSING_DATA: 400,
      AVATAR_NOT_FOUND: 400,
      PREMIUM_REQUIRED: 403
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.setBackground = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { backgroundId } = req.body;

    await UserService.setBackground(userId, backgroundId);
    res.status(200).json({ message: 'Background updated successfully' });
  } catch (err) {
    const map = {
      MISSING_DATA: 400,
      BACKGROUND_NOT_FOUND: 400,
      PREMIUM_REQUIRED: 403
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.getCurrentAvatar = async (req, res) => {
  try {
    const userId = req.user?.id;
    const avatar = await UserService.getCurrentAvatar(userId);
    res.status(200).json({ avatar });
  } catch (err) {
    const map = {
      NO_AVATAR: 404,
      AVATAR_DATA_MISSING: 404
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.getCurrentBackground = async (req, res) => {
  try {
    const userId = req.user?.id;
    const background = await UserService.getCurrentBackground(userId);
    res.status(200).json({ background });
  } catch (err) {
    const map = {
      NO_BACKGROUND: 404,
      BACKGROUND_DATA_MISSING: 404
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.getCurrentProfile = async (req, res) => {
  try {
    const userId = req.user?.id;
    const profile = await UserService.getCurrentProfile(userId);
    res.status(200).json(profile);
  } catch (err) {
    const map = {
      USER_NOT_FOUND: 404
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { username, firstName, lastName, dob } = req.body;

    await UserService.updateProfile(userId, { username, firstName, lastName, dob });
    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (err) {
    const map = {
      USERNAME_EXISTS: 409
    };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};
exports.getLeaderboard = async (req, res) => {
  try {
    const { type, limit } = req.query;
    const data = await UserService.getLeaderboard(type, parseInt(limit) || 20);
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
exports.buyPremium = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { type, plan, paymentId } = req.body;

    if (type === 'premium_token') {
      const planInfo = premiumCosts[plan];
      if (!planInfo) return res.status(400).json({ message: 'Invalid plan' });
      const expiry = await UserService.buyPremium(userId, plan, 'tokens');
      return res.status(200).json({ message: 'Premium purchased with tokens', plan, expires: expiry });
    } else if (type === 'premium_money') {
      const planInfo = premiumCosts[plan];
      if (!planInfo) return res.status(400).json({ message: 'Invalid plan' });
      if (!paymentId) return res.status(400).json({ message: 'Missing paymentId' });
      const expiry = await UserService.buyPremium(userId, plan, 'money');
      return res.status(200).json({ message: 'Premium purchased with money', plan, expires: expiry });
    } else {
      return res.status(400).json({ message: 'Invalid purchase type' });
    }
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};
exports.getDailyXP = async (req, res) => {
  try {
    const userId = req.user?.id;
    const date = req.query.date || new Date().toISOString().slice(0, 10);
    const xp = await UserService.getDailyXP(userId, date);
    res.status(200).json({ date, xp });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
exports.setLanguage = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { language } = req.body;

    if (!language) return res.status(400).json({ message: 'Language is required' });

    await UserService.setLanguage(userId, language);
    res.status(200).json({ message: 'Language updated successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getLanguage = async (req, res) => {
  try {
    const userId = req.user?.id;

    const language = await UserService.getLanguage(userId);
    res.status(200).json({ language });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

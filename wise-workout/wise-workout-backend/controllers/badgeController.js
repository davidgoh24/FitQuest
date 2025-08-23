const BadgeService = require('../services/badgeService');

exports.getAllBadges = async (req, res) => {
  const badges = await BadgeService.getAllBadges();
  res.json(badges);
};

exports.getUserBadges = async (req, res) => {
  const userId = req.user?.id;
  const badges = await BadgeService.getUserBadges(userId);
  res.json(badges);
};

exports.grantBadge = async (req, res) => {
  const userId = req.user?.id;
  const { badgeId } = req.body;
  await BadgeService.grantBadge(userId, badgeId);
  res.json({ message: 'Badge granted' });
};

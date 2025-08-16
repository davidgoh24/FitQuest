const FriendService = require('../services/friendService');

exports.sendRequest = async (req, res) => {
  const userId = req.user.id;
  const { friendId } = req.body;
  if (!friendId) return res.status(400).json({ message: 'Missing friendId' });
  await FriendService.sendRequest(userId, friendId);
  res.json({ message: 'Friend request sent' });
};

exports.acceptRequest = async (req, res) => {
  const userId = req.user.id;
  const { friendId } = req.body;
  if (!friendId) return res.status(400).json({ message: 'Missing friendId' });
  await FriendService.acceptRequest(userId, friendId);
  res.json({ message: 'Friend request accepted' });
};

exports.rejectRequest = async (req, res) => {
  const userId = req.user.id;
  const { friendId } = req.body;
  if (!friendId) return res.status(400).json({ message: 'Missing friendId' });
  await FriendService.rejectRequest(userId, friendId);
  res.json({ message: 'Friend request rejected' });
};

exports.getFriends = async (req, res) => {
  const userId = req.user.id;
  const friends = await FriendService.getFriends(userId);
  res.json(friends);
};

exports.getPendingRequests = async (req, res) => {
  const userId = req.user.id;
  const requests = await FriendService.getPendingRequests(userId);
  res.json(requests);
};

exports.getSentRequests = async (req, res) => {
  const userId = req.user.id;
  const sent = await FriendService.getSentRequests(userId);
  res.json(sent);
};
exports.searchUsers = async (req, res) => {
  const userId = req.user.id;
  const query = req.query.query;
  if (!query || !query.trim()) return res.json([]);
  const results = await FriendService.searchUsers(userId, query.trim());
  res.json(results);
};

exports.getPremiumFriends = async (req, res) => {
  const userId = req.user.id;
  const premiumFriends = await FriendService.getPremiumFriends(userId);
  res.json(premiumFriends);
};

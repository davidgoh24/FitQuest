const UserService = require('../services/userService');

exports.getDashboardStats = async (req, res) => {
  try {
    const stats = await UserService.getDashboardStats();
    res.status(200).json(stats);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch stats' });
  }
};
exports.getAllUsers = async (req, res) => {
  try {
    const users = await UserService.getAllUsers();
    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch users' });
  }
};
exports.getPremiumUsers = async(req, res) => {
  try {
    const premiumUsers = await UserService.getPremiumUsers();
    res.status(200).json(premiumUsers);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch premium users', error: err.message });
  }
}
exports.suspendUser = async (req, res) => {
  try {
    const userId = req.params.id;
    await UserService.suspendUser(userId);
    res.status(200).json({ message: 'User suspended' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to suspend user' });
  }
};
exports.unsuspendUser = async (req, res) => {
  try {
    const userId = req.params.id;
    await UserService.unsuspendUser(userId);
    res.status(200).json({ message: 'User unsuspended' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to unsuspend user' });
  }
};

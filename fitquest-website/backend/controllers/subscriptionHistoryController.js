const SubscriptionHistoryService = require('../services/subscriptionHistoryService');

exports.getAll = async (req, res) => {
  try {
    const { plan, search } = req.query;
    const data = await SubscriptionHistoryService.getAll(plan, search);
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getByUserId = async (req, res) => {
  try {
    const { userId } = req.params;
    const data = await SubscriptionHistoryService.getByUserId(userId);
    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

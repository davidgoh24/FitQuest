const PrizeService = require('../services/prizeService');

exports.getAllPrizes = async (req, res) => {
  try {
    const prizes = await PrizeService.getAllPrizes();
    res.status(200).json({ prizes });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

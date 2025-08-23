const SpinService = require('../services/spinService');

exports.spin = async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  const forceSpin = req.query.force === 'true';

  try {
    const result = await SpinService.performSpin(userId, forceSpin);
    res.json(result);
  } catch (err) {
    if (err.message === 'ALREADY_SPUN') {
      return res.status(403).json({ message: 'Already spun today' });
    }
    if (err.message === 'NOT_ENOUGH_TOKENS') {
      return res.status(403).json({ message: 'Not enough tokens to re-spin' });
    }
    if (err.message === 'NO_PRIZES') {
      return res.status(500).json({ message: 'No prizes configured' });
    }
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

exports.getSpinStatus = async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  try {
    const status = await SpinService.getSpinStatus(userId);
    res.json(status);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

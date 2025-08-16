const FeedbackService = require('../services/feedbackService');

exports.getUserFeedback = async (req, res) => {
  try {
    const userId = parseInt(req.query.user_id);
    if (!userId) return res.status(400).json({ message: 'Invalid user_id' });

    const feedback = await FeedbackService.getUserFeedback(userId);
    if (!feedback) return res.status(404).json({ message: 'No feedback found' });

    res.status(200).json(feedback);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch user feedback' });
  }
};

exports.getAllFeedbacks = async (req, res) => {
  try {
    const { status = 'All', search = '' } = req.query;
    const feedbacks = await FeedbackService.getAllFeedbacks({ status, search });
    res.status(200).json(feedbacks);
  } catch {
    res.status(500).json({ message: 'Failed to fetch feedbacks' });
  }
};

exports.setFeedbackStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    if (!['pending', 'accepted', 'rejected'].includes(status))
      return res.status(400).json({ message: 'Invalid status' });
    await FeedbackService.setFeedbackStatus(id, status);
    res.status(200).json({ message: `Feedback status set to ${status}` });
  } catch {
    res.status(400).json({ message: 'Failed to update status' });
  }
};
exports.getFeedbackSummary = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const summary = await FeedbackService.getFeedbackSummary(limit);
    res.status(200).json(summary);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: 'Failed to fetch feedback summary' });
  }
};


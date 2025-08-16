const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');

router.get('/admin/feedbacks', feedbackController.getAllFeedbacks);
router.post('/admin/feedbacks/:id/status', feedbackController.setFeedbackStatus);
router.get('/admin/feedbacks/summary', feedbackController.getFeedbackSummary);
router.get('/admin/feedbacks/user', feedbackController.getUserFeedback);

module.exports = router;

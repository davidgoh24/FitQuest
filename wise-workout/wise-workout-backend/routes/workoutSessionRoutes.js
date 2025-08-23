const express = require('express');
const router = express.Router();
const workoutSessionController = require('../controllers/workoutSessionController');

router.post('/sessions', workoutSessionController.saveWorkoutSession);

router.get('/sessions', workoutSessionController.getUserWorkoutSessions);

router.get('/sessions/today/summary', workoutSessionController.getTodayCaloriesSummary);

router.get('/sessions/summary', workoutSessionController.getDailyCaloriesSummaryRange);

router.get('/sessions/hourly-calories', workoutSessionController.getHourlyCaloriesForDate);

router.get('/sessions/:id/intensity', workoutSessionController.getSessionIntensity);

module.exports = router;
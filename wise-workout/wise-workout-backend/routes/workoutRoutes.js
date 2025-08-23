const express = require('express');
const router = express.Router();
const workoutController = require('../controllers/workoutController');

// Get all workouts in a category
router.get('/category/:categoryKey', workoutController.getWorkoutsByCategory);

// Get workout by ID
router.get('/:id', workoutController.getWorkoutById);

module.exports = router;

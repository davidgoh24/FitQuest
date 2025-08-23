const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exerciseController');

router.get('/', exerciseController.getAllExercises);
router.get('/workout/:workoutId', exerciseController.getExercisesByWorkout);
router.post('/by-names', exerciseController.getExercisesByNames);

module.exports = router;

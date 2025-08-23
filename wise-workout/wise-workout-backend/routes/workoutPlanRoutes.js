const express = require('express');
const router = express.Router();
const { saveWorkoutPlan, getWorkoutPlansByUser, getLatestWorkoutPlan, updateEstimation } = require('../controllers/workoutPlanController');

router.post('/save', saveWorkoutPlan);
router.get('/my-plans', getWorkoutPlansByUser);
router.get('/latest', getLatestWorkoutPlan);
router.patch('/estimation', updateEstimation);

module.exports = router;

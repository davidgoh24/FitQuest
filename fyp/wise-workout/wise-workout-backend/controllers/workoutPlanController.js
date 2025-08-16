const WorkoutPlanService = require('../services/workoutPlanService');

exports.saveWorkoutPlan = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { planTitle, days, estimationText } = req.body; // <-- NEW
    const planId = await WorkoutPlanService.saveWorkoutPlan(userId, planTitle, days, estimationText);
    res.status(201).json({ message: 'Workout plan saved', planId });
  } catch (err) {
    const map = { MISSING_DATA: 400 };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};

exports.getWorkoutPlansByUser = async (req, res) => {
  try {
    const userId = req.user?.id;
    const plans = await WorkoutPlanService.getWorkoutPlansByUser(userId);
    res.status(200).json(plans);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getLatestWorkoutPlan = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const plan = await WorkoutPlanService.getLatestWorkoutPlan(userId);
    if (!plan) return res.status(404).json({ message: 'No saved plan found' });
    res.status(200).json(plan);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getLatestWorkoutPlan = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    const plan = await WorkoutPlanService.getLatestWorkoutPlan(userId);
    if (!plan) return res.status(404).json({ message: 'No saved plan found' });
    res.status(200).json(plan);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateEstimation = async (req, res) => {
  try {
    const userId = req.user?.id;
    const { planId, estimationText } = req.body;
    await WorkoutPlanService.updateEstimation(planId, userId, estimationText);
    res.status(200).json({ message: 'Estimation updated' });
  } catch (err) {
    const map = { MISSING_DATA: 400, NOT_FOUND: 404 };
    res.status(map[err.message] || 500).json({ message: err.message });
  }
};


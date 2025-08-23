// aiController.js

const UserPreferencesModel = require('../models/userPreferencesModel');
const ExerciseModel = require('../models/exerciseModel');
const { callQwenAI } = require('../services/aiService');
const UserAIWorkoutPlanModel = require('../models/userAIWorkoutPlanModel');

exports.generateAIPlan = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const prefs = await UserPreferencesModel.getPreferences(userId);
    const exercises = await ExerciseModel.getAllExercises();

    const aiInput = { preferences: prefs, exercises };

    // Call Qwen (send aiInput as prompt/context)
    const aiPlan = await callQwenAI(aiInput);

    // Optionally: save plan to user_ai_workout_plans
    await UserAIWorkoutPlanModel.savePlan(userId, aiPlan);

    res.json({ plan: aiPlan, preferences: prefs });
  } catch (err) {
    console.error('AI Plan Error:', err);
    res.status(500).json({ message: 'Failed to generate AI fitness plan' });
  }
};

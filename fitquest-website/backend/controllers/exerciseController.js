const ExerciseService = require('../services/exerciseService');

exports.getAllExercises = async (req, res) => {
  try {
    const exercises = await ExerciseService.getAllExercises();
    res.json(exercises);
  } catch (err) {
    console.error('Error fetching exercises:', err);
    res.status(500).json({ message: 'Failed to fetch exercises' });
  }
};

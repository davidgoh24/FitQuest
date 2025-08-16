const ExerciseService = require('../services/exerciseService');

exports.getExercisesByWorkout = async (req, res) => {
  const { workoutId } = req.params;
  console.log(`📥 [GET] /exercises/workout/${workoutId}`);

  if (!workoutId) return res.status(400).json({ message: 'Missing workoutId' });

  const exercises = await ExerciseService.getExercisesByWorkout(workoutId);
  console.log('📤 Returning exercises:', exercises);
  res.json(exercises);
};

exports.getExercisesByNames = async (req, res) => {
  const { names } = req.body;
  if (!Array.isArray(names) || names.length === 0) {
    return res.status(400).json({ message: 'names must be a non-empty array' });
  }
  try {
    const exercises = await ExerciseService.getExercisesByNames(names);
    res.json(exercises);
  } catch (err) {
    console.error('❌ getExercisesByNames ERROR:', err);
    res.status(500).json({ message: 'Failed to fetch exercises by names' });
  }
};

exports.getAllExercises = async (req, res) => {
    console.log('📥 [GET] /exercises - Fetching all exercises');

    try {
      const exercises = await ExerciseService.getAllExercises();
      console.log(`📤 Returning ${exercises.length} exercises`);
      res.json(exercises);
    } catch (err) {
      console.error('❌ getAllExercises ERROR:', err);
      res.status(500).json({ message: 'Failed to fetch all exercises' });
    }
};

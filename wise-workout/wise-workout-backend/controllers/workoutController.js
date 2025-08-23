const WorkoutService = require('../services/workoutService');

exports.getWorkoutsByCategory = async (req, res) => {
  const { categoryKey } = req.params;
  console.log(`📥 GET /workouts/category/${categoryKey}`);
  if (!categoryKey) return res.status(400).json({ message: 'Missing categoryKey' });

  const workouts = await WorkoutService.getWorkoutsByCategory(categoryKey);
  console.log('📤 Workouts:', workouts);
  res.json(workouts);
};

exports.getWorkoutById = async (req, res) => {
  const { id } = req.params;
  console.log(`📥 GET /workouts/${id}`);
  const workout = await WorkoutService.getWorkoutById(id);
  if (!workout) {
    console.log('❌ Workout not found');
    return res.status(404).json({ message: 'Workout not found' });
  }
  console.log('📤 Workout:', workout);
  res.json(workout);
};

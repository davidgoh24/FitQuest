const ExerciseModel = require('../models/exerciseModel');

async function getAllExercises() {
  return await ExerciseModel.getAllExercises();
}

module.exports = {
  getAllExercises
};

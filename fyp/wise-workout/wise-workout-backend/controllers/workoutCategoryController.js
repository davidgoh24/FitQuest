const WorkoutCategoryService = require('../services/workoutCategoryService');

exports.getAllCategories = async (req, res) => {
  const categories = await WorkoutCategoryService.getAllCategories();
  res.json(categories);
};

exports.getCategoryById = async (req, res) => {
  const categoryId = req.params.id;
  const category = await WorkoutCategoryService.getCategoryById(categoryId);
  if (!category) {
    return res.status(404).json({ message: 'Category not found' });
  }
  res.json(category);
};

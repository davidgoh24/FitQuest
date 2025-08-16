const WorkoutCategoryModel = require('../models/workoutCategoryModel');

class WorkoutCategoryService {
  static async getAllCategories() {
    return await WorkoutCategoryModel.getAllCategories();
  }

  static async getCategoryById(categoryId) {
    return await WorkoutCategoryModel.getCategoryById(categoryId);
  }
}

module.exports = WorkoutCategoryService;

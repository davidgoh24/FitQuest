const UserWorkoutPlanModel = require('../models/userWorkoutPlanModel');

class UserWorkoutPlanService {
  static async getPlans(userId) {
    return await UserWorkoutPlanModel.getPlansByUserId(userId);
  }

  static async createPlan(userId, planTitle) {
    return await UserWorkoutPlanModel.createPlan(userId, planTitle);
  }

  static async getItems(planId) {
    return await UserWorkoutPlanModel.getItemsByPlanId(planId);
  }

  static async deletePlan(planId, userId) {
    return await UserWorkoutPlanModel.deletePlan(planId, userId);
  }

  static async addItem(userId, planId, item) {
    return UserWorkoutPlanModel.addItemForUser(userId, planId, item);
  }
}

module.exports = UserWorkoutPlanService;

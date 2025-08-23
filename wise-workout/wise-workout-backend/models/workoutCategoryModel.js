const db = require('../config/db');

class WorkoutCategoryModel {
  static async getAllCategories() {
    const [rows] = await db.execute(`
      SELECT
        category_id AS categoryId,
        category_name AS categoryName,
        category_key AS categoryKey,
        category_description AS categoryDescription,
        image_url AS imageUrl
      FROM workout_categories
    `);
    return rows;
  }

  static async getCategoryById(categoryId) {
    const [rows] = await db.execute(`
      SELECT
        category_id AS categoryId,
        category_name AS categoryName,
        category_key AS categoryKey,
        category_description AS categoryDescription,
        image_url AS imageUrl
      FROM workout_categories
      WHERE category_id = ?
    `, [categoryId]);
    return rows[0];
  }
}

module.exports = WorkoutCategoryModel;

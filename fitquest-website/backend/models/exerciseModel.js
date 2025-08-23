const db = require('../config/db');

async function getAllExercises() {
  const sql = `
    SELECT 
      exercise_id, 
      exercise_key, 
      exercise_name 
    FROM exercises
    ORDER BY exercise_name ASC
  `;
  const [rows] = await db.execute(sql);
  return rows;
}

module.exports = {
  getAllExercises
};

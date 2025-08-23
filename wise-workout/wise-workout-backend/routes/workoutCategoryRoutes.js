const express = require('express');
const router = express.Router();
const authenticateUser = require('../middlewares/authMiddleware');
const workoutCategoryController = require('../controllers/workoutCategoryController');

router.get('/',  workoutCategoryController.getAllCategories);
router.get('/:id', authenticateUser, workoutCategoryController.getCategoryById);

module.exports = router;

const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exerciseController');

router.get('/admin/exercises', exerciseController.getAllExercises);

module.exports = router;

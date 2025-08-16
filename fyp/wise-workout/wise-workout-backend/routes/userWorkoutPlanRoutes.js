const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/userWorkoutPlanController');

// 1. Get all my plans
router.get('/', ctrl.getMyPlans);

// 2. Create plan
router.post('/', ctrl.createPlan);

// 3. Get items for a plan
router.get('/:planId/items', ctrl.getItemsByPlan);

// 4. Delete plan
router.delete('/:planId', ctrl.deletePlan);

// add under your other routes
router.post('/:planId/item', ctrl.addOneItem);


module.exports = router;

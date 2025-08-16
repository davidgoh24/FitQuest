const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.get('/admin/stats', userController.getDashboardStats);
router.post('/admin/users/:id/suspend', userController.suspendUser);
router.post('/admin/users/:id/unsuspend', userController.unsuspendUser);
router.get('/admin/users', userController.getAllUsers);
router.get('/admin/premium-users', userController.getPremiumUsers);

module.exports = router;

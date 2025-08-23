const express = require('express');
const router = express.Router();
const {
  setAvatar,
  setBackground,
  getCurrentAvatar,
  getCurrentBackground, 
  getCurrentProfile,
  updateProfile,
  getLeaderboard,
  buyPremium,
  getDailyXP,
  setLanguage,
  getLanguage,
  changePassword
} = require('../controllers/userController');


router.post('/set-avatar', setAvatar);
router.post('/set-background', setBackground);
router.get('/current-avatar', getCurrentAvatar);
router.get('/current-background', getCurrentBackground); 
router.get('/current-profile', getCurrentProfile);
router.post('/update-profile', updateProfile);
router.get('/leaderboard', getLeaderboard);
router.post('/buy-premium', buyPremium);
router.get('/daily-xp', getDailyXP);
router.put('/language', setLanguage);
router.get('/language', getLanguage);
router.post('/change-password', changePassword);

module.exports = router;

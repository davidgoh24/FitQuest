const express = require('express');
const router = express.Router();
const prizeController = require('../controllers/prizeController');

router.get('/', prizeController.getAllPrizes);

module.exports = router;

const express = require('express');
const router = express.Router();
const { spin, getSpinStatus } = require('../controllers/spinController');

router.get('/spin', spin);
router.get('/spin/status', getSpinStatus);

module.exports = router;

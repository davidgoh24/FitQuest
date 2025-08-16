const express = require('express');
const router = express.Router();
const tournamentController = require('../controllers/tournamentController');

router.post('/admin/tournaments', tournamentController.createTournament);
router.get('/admin/tournaments', tournamentController.getAllTournaments);
router.put('/admin/tournaments/:id', tournamentController.updateTournament);

module.exports = router;

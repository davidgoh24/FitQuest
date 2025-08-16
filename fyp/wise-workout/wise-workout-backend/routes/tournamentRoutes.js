const express = require('express');
const router = express.Router();
const authenticateUser = require('../middlewares/authMiddleware');
const tournamentController = require('../controllers/tournamentController');

router.get('/all', authenticateUser, tournamentController.getAllTournaments);
router.get('/name-enddate', authenticateUser, tournamentController.getAllTournamentNamesAndEndDates);
router.get('/with-participants', tournamentController.getTournamentsWithParticipantCounts);
router.get('/:tournamentId/participants', authenticateUser, tournamentController.getTournamentParticipants);
router.post('/:tournamentId/join', authenticateUser, tournamentController.joinTournament);

module.exports = router;

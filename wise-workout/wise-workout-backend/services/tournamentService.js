const Tournament = require('../models/tournamentModel');

async function fetchAllTournaments() {
  return await Tournament.getAllTournaments();
}

async function getTournamentNamesAndEndDates() {
  return await Tournament.getTournamentNamesAndEndDates();
}

async function getTournamentsWithParticipantCounts() {
  return await Tournament.getTournamentsWithParticipantCounts();
}

async function getTournamentParticipants(tournamentId) {
  return await Tournament.getTournamentParticipants(tournamentId);
}

async function joinTournament(tournamentId, userId) {
  return await Tournament.joinTournament(tournamentId, userId);
}

module.exports = {
  fetchAllTournaments,
  getTournamentNamesAndEndDates,
  getTournamentsWithParticipantCounts,
  getTournamentParticipants,
  joinTournament,
};
const TournamentModel = require('../models/tournamentModel');

class TournamentService {
  static async createTournament(data) {
    return await TournamentModel.insertTournament(data);
  }

  static async fetchAllTournaments() {
    return await TournamentModel.getAllTournaments();
  }

  static async editTournament(id, data) {
    return await TournamentModel.updateTournament(id, data);
  }
}

module.exports = TournamentService;

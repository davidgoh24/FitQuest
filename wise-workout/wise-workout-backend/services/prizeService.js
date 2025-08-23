const PrizeModel = require('../models/prizeModel');

class PrizeService {
  static async getAllPrizes() {
    return await PrizeModel.getAll();
  }
}

module.exports = PrizeService;

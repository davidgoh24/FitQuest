const TournamentService = require('../services/tournamentService');

exports.createTournament = async (req, res) => {
  try {
    const {
      title, description, startDate, endDate, features, target_exercise_pattern,
      reward_xp_first, reward_xp_second, reward_xp_other,
      reward_tokens_first, reward_tokens_second, reward_tokens_other
    } = req.body;

    if (!title || !description || !startDate || !endDate || !target_exercise_pattern) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const tournament = await TournamentService.createTournament({
      title,
      description,
      startDate,
      endDate,
      features: features || [],
      target_exercise_pattern,
      reward_xp_first, reward_xp_second, reward_xp_other,
      reward_tokens_first, reward_tokens_second, reward_tokens_other
    });

    res.status(201).json(tournament);
  } catch (err) {
    res.status(500).json({ message: 'Failed to create tournament', error: err.message });
  }
};

exports.getAllTournaments = async (req, res) => {
  try {
    const tournaments = await TournamentService.fetchAllTournaments();
    res.status(200).json(tournaments);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch tournaments', error: err.message });
  }
};

exports.updateTournament = async (req, res) => {
  try {
    const id = req.params.id;
    const {
      title, description, startDate, endDate, features, target_exercise_pattern,
      reward_xp_first, reward_xp_second, reward_xp_other,
      reward_tokens_first, reward_tokens_second, reward_tokens_other
    } = req.body;

    await TournamentService.editTournament(id, {
      title,
      description,
      startDate,
      endDate,
      features: features || [],
      target_exercise_pattern,
      reward_xp_first, reward_xp_second, reward_xp_other,
      reward_tokens_first, reward_tokens_second, reward_tokens_other
    });

    res.status(200).json({ message: 'Tournament updated successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to update tournament', error: err.message });
  }
};

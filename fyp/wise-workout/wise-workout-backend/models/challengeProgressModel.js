const db = require('../config/db');

const ChallengeProgressModel = {
  insertInitialProgress: async (inviteId, userId) => {
    const [r] = await db.execute(
      'INSERT INTO challenge_progress (challenge_invite_id, user_id, progress_value) VALUES (?, ?, 0)',
      [inviteId, userId]
    );
    return r;
  },
  incrementProgress: async (inviteId, userId, delta) => {
    const [r] = await db.execute(
      'UPDATE challenge_progress SET progress_value = progress_value + ? WHERE challenge_invite_id = ? AND user_id = ?',
      [delta, inviteId, userId]
    );
    return r;
  },

};

module.exports = ChallengeProgressModel;

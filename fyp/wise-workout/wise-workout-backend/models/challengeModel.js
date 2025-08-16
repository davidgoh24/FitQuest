const db = require('../config/db');

const ChallengeModel = {
  getAllChallenges: async () => {
    const [rows] = await db.execute('SELECT id, type, value, unit, duration FROM challenges');
    return rows;
  },
  findChallengeIdByTitle: async (title) => {
    const [rows] = await db.execute('SELECT id FROM challenges WHERE type = ?', [title]);
    return rows[0]?.id || null;
  },
  getLeaderboardsByUser: async (userId) => {
    const [rows] = await db.execute(
      `SELECT
         ci.id AS invite_id,
         c.type, c.value, c.unit, c.duration,
         u.id AS user_id, u.username,
         CAST(COALESCE(SUM(cp.progress_value), 0) AS UNSIGNED) AS progress,
         ci.accepted_at,
         ci.expires_at,
         ci.completed_at IS NOT NULL AS is_completed,
         GREATEST(0, TIMESTAMPDIFF(DAY, NOW(), ci.expires_at)) AS days_left,
         TIMESTAMPDIFF(DAY, ci.accepted_at, ci.expires_at) AS total_days
       FROM challenge_invites ci
       JOIN challenges c ON c.id = ci.challenge_id
       JOIN (
         SELECT id, sender_id AS user_id FROM challenge_invites
         UNION ALL
         SELECT id, receiver_id AS user_id FROM challenge_invites
       ) p ON p.id = ci.id
       JOIN users u ON u.id = p.user_id
       LEFT JOIN challenge_progress cp
         ON cp.challenge_invite_id = ci.id AND cp.user_id = u.id
       WHERE ci.status = 'accepted'
         AND (ci.sender_id = ? OR ci.receiver_id = ?)
       GROUP BY ci.id, u.id
       ORDER BY ci.id, progress DESC`,
      [userId, userId]
    );
    return rows;
  }  
};

module.exports = ChallengeModel;

const db = require('../config/db');

const ChallengeInvitesModel = {
  getPendingInvites: async (userId) => {
    const [rows] = await db.execute(
      `SELECT ci.id, c.type, c.value, c.unit, c.duration, ci.custom_value, ci.custom_duration_value, ci.custom_duration_unit, u.username as senderName
       FROM challenge_invites ci
       JOIN challenges c ON ci.challenge_id = c.id
       JOIN users u ON ci.sender_id = u.id
       WHERE ci.receiver_id = ? AND ci.status = 'pending'`,
      [userId]
    );
    return rows;
  },
  getAcceptedChallenges: async (userId) => {
    const [rows] = await db.execute(
      `SELECT
         ci.id,
         c.type,
         c.value,
         c.unit,
         c.duration,
         ci.custom_value,
         ci.custom_duration_value,
         ci.custom_duration_unit,
         GREATEST(0, DATEDIFF(ci.expires_at, NOW())) AS daysLeft,
         ci.completed_at IS NOT NULL AS is_completed,
         CASE WHEN ci.sender_id = ? THEN r.username ELSE s.username END AS opponentName
       FROM challenge_invites ci
       JOIN challenges c ON ci.challenge_id = c.id
       JOIN users s ON s.id = ci.sender_id
       JOIN users r ON r.id = ci.receiver_id
       WHERE (ci.receiver_id = ? OR ci.sender_id = ?)
         AND ci.status = 'accepted'
         AND (ci.expires_at IS NULL OR ci.expires_at > NOW())`,
      [userId, userId, userId]
    );
    return rows;
  },  
  getActiveAcceptedInvitesForUser: async (userId) => {
    const [rows] = await db.execute(
      `SELECT ci.id AS invite_id, c.type, c.unit
       FROM challenge_invites ci
       JOIN challenges c ON c.id = ci.challenge_id
       WHERE (ci.receiver_id = ? OR ci.sender_id = ?)
         AND ci.status = 'accepted'
         AND ci.completed_at IS NULL
         AND (ci.expires_at IS NULL OR ci.expires_at > NOW())`,
      [userId, userId]
    );
    return rows;
  },  
  getInviteForAcceptance: async (inviteId) => {
    const [rows] = await db.execute(
      `SELECT ci.id, ci.sender_id, ci.receiver_id, ci.custom_duration_value, ci.custom_duration_unit, c.duration
       FROM challenge_invites ci
       JOIN challenges c ON ci.challenge_id = c.id
       WHERE ci.id = ? FOR UPDATE`,
      [inviteId]
    );
    return rows[0] || null;
  },  
  markInviteAccepted: async (inviteId, acceptedAt, expiresAt) => {
    const [r] = await db.execute(
      'UPDATE challenge_invites SET status = ?, accepted_at = ?, expires_at = ? WHERE id = ?',
      ['accepted', acceptedAt, expiresAt, inviteId]
    );
    return r;
  },
  markInviteRejected: async (inviteId) => {
    const [r] = await db.execute(
      'UPDATE challenge_invites SET status = ? WHERE id = ?',
      ['rejected', inviteId]
    );
    return r;
  },
  createChallengeInvite: async (challengeId, senderId, receiverId, customValue, customDurationValue, customDurationUnit) => {
    const [result] = await db.execute(
      `INSERT INTO challenge_invites
        (challenge_id, sender_id, receiver_id, custom_value, custom_duration_value, custom_duration_unit)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [challengeId, senderId, receiverId, customValue, customDurationValue, customDurationUnit]
    );
    return result;
  },
  getPremiumFriendsToChallenge: async (userId, title) => {
    const [rows] = await db.execute(
      `SELECT u.id, u.username, u.firstName, u.lastName, u.email, u.role,
              a.image_url AS avatar_url, b.image_url AS background_url
       FROM friends f
       JOIN users u ON u.id = f.friend_id
       LEFT JOIN avatars a ON u.avatar_id = a.id
       LEFT JOIN backgrounds b ON u.background_id = b.id
       WHERE f.user_id = ?
         AND f.status = 'accepted'
         AND u.role = 'premium'
         AND NOT EXISTS (
           SELECT 1
           FROM challenge_invites ci
           JOIN challenges c ON c.id = ci.challenge_id
           WHERE c.type = ?
             AND (
               (ci.sender_id = ? AND ci.receiver_id = u.id)
               OR
               (ci.sender_id = u.id AND ci.receiver_id = ?)
             )
             AND (
               ci.status = 'pending'
               OR (ci.status = 'accepted' AND ci.expires_at > NOW())
             )
         )`,
      [userId, title, userId, userId]
    );
    return rows;
  },
  markChallengeCompleted: async (inviteId) => {
    return await db.execute(
      `UPDATE challenge_invites SET completed_at = NOW() WHERE id = ?`,
      [inviteId]
    );
  },
  
  getInviteProgressAndUsers: async (inviteId) => {
    const [rows] = await db.execute(
      `SELECT cp.user_id, cp.progress_value, ci.custom_value, c.value
       FROM challenge_progress cp
       JOIN challenge_invites ci ON ci.id = cp.challenge_invite_id
       JOIN challenges c ON c.id = ci.challenge_id
       WHERE ci.id = ?`,
      [inviteId]
    );
    return rows;
  }
};

module.exports = ChallengeInvitesModel;

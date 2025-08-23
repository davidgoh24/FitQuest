const db = require('../config/db');

async function getAllTournaments() {
  const [rows] = await db.query(
    'SELECT * FROM tournaments WHERE endDate > NOW() ORDER BY startDate ASC'
  );
  return rows;
}

async function getTournamentNamesAndEndDates() {
  const [rows] = await db.query(
    'SELECT id, title, endDate FROM tournaments WHERE endDate > NOW() ORDER BY startDate ASC'
  );
  return rows;
}

async function getTournamentsWithParticipantCounts() {
  const [rows] = await db.query(
    `SELECT t.id, t.title, t.endDate, COUNT(tp.id) AS participants
     FROM tournaments t
     LEFT JOIN tournament_participants tp ON t.id = tp.tournament_id
     WHERE t.endDate > NOW()
     GROUP BY t.id, t.title, t.endDate
     ORDER BY t.startDate ASC`
  );
  return rows;
}

async function getTournamentParticipants(tournamentId) {
  const sql = `
    SELECT
      tp.user_id AS userId,
      u.username,
      u.firstName,
      u.lastName,
      u.avatar_id,
      a.image_url AS avatar_url,
      u.background_id,
      b.image_url AS background_url,
      tp.progress
    FROM tournament_participants tp
    JOIN users u ON tp.user_id = u.id
    LEFT JOIN avatars a ON u.avatar_id = a.id
    LEFT JOIN backgrounds b ON u.background_id = b.id
    WHERE tp.tournament_id = ?
    ORDER BY tp.progress DESC, tp.joined_at ASC
  `;
  const [rows] = await db.execute(sql, [tournamentId]);
  return rows;
}

async function joinTournament(tournamentId, userId) {
  const [existing] = await db.query(
    'SELECT id FROM tournament_participants WHERE tournament_id = ? AND user_id = ?',
    [tournamentId, userId]
  );
  if (existing.length > 0) return { status: 'already_joined' };
  await db.query(
    'INSERT INTO tournament_participants (tournament_id, user_id, progress) VALUES (?, ?, 0)',
    [tournamentId, userId]
  );
  return { status: 'joined' };
}

async function getJoinedTournamentsByUser(userId) {
  const sql = `
    SELECT t.id AS tournament_id, t.title, t.target_exercise_pattern
    FROM tournaments t
    INNER JOIN tournament_participants tp ON tp.tournament_id = t.id
    WHERE tp.user_id = ?
      AND t.endDate > NOW()
  `;
  const [rows] = await db.execute(sql, [userId]);
  return rows;
}

async function incrementTournamentProgress(tournamentId, userId, delta) {
  const [r] = await db.execute(
    'UPDATE tournament_participants SET progress = progress + ? WHERE tournament_id = ? AND user_id = ?',
    [delta, tournamentId, userId]
  );
  return r;
}

module.exports = {
  getAllTournaments,
  getTournamentNamesAndEndDates,
  getTournamentsWithParticipantCounts,
  getTournamentParticipants,
  joinTournament,
  getJoinedTournamentsByUser,
  incrementTournamentProgress,
};

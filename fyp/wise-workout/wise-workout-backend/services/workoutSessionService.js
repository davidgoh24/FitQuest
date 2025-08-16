const WorkoutSessionModel = require('../models/workoutSessionModel');
const ExerciseLogsModel = require('../models/exerciseLogsModel');
const BadgeService = require('../services/badgeService');
const DailyQuestModel = require('../models/dailyQuestModel');
const ChallengeInvitesModel = require('../models/challengeInvitesModel');
const ChallengeProgressModel = require('../models/challengeProgressModel');
const TournamentModel = require('../models/tournamentModel');
const ChallengeService = require('../services/challengeService'); 

class WorkoutSessionService {
  static async saveWorkoutSession(sessionData, exerciseLogs) {
    try {
      const sessionId = await WorkoutSessionModel.createSession(sessionData);

      for (const exercise of exerciseLogs) {
        await ExerciseLogsModel.logExercise(sessionId, exercise);
      }

      const userId = sessionData.userId;
      const today = new Date().toISOString().slice(0, 10);

      await DailyQuestModel.markQuestDone(userId, 'ANY_WORKOUT', today);

      const sessionCount = await WorkoutSessionModel.countSessionsByUserId(userId);
      if (sessionCount >= 1) await BadgeService.grantBadge(userId, 1);
      if (sessionCount >= 10) await BadgeService.grantBadge(userId, 3);
      if (sessionCount >= 50) await BadgeService.grantBadge(userId, 10);

      const totalCalories = await WorkoutSessionModel.getTotalCaloriesBurnedByUserId(userId);
      if (totalCalories >= 1000) await BadgeService.grantBadge(userId, 4);

      const norm = s =>
        (s || '')
          .toString()
          .toLowerCase()
          .replace(/[-_]/g, ' ')
          .replace(/\s+/g, ' ')
          .trim();

      const sumReps = arr => {
        if (!arr || !Array.isArray(arr)) return 0;
        let t = 0;
        for (const s of arr) {
          const v = typeof s?.reps === 'number' ? s.reps : parseInt(s?.reps || 0, 10);
          if (!Number.isNaN(v)) t += v;
        }
        return t;
      };

      let pushUps = 0;
      let squats = 0;
      let jumpingJacks = 0;
      const repsByName = {};

      for (const ex of exerciseLogs || []) {
        const name = norm(ex.exercise_name || ex.exerciseName);
        const reps = sumReps(ex.sets_data || ex.setsData);

        if (!repsByName[name]) repsByName[name] = 0;
        repsByName[name] += reps;

        if (/push ?ups?/.test(name)) {
          pushUps += reps;
        } else if (/squats?/.test(name)) {
          squats += reps;
        } else if (/jump(ing)? ?jacks?/.test(name)) {
          jumpingJacks += reps;
        }
      }

      const invites = await ChallengeInvitesModel.getActiveAcceptedInvitesForUser(userId);
      for (const inv of invites) {
        const unit = norm(inv.unit);
        let delta = 0;
        if (unit.includes('push up')) delta = pushUps;
        else if (unit.includes('squat')) delta = squats;
        else if (unit.includes('jumping jack')) delta = jumpingJacks;

        if (delta > 0) {
          await ChallengeProgressModel.incrementProgress(inv.invite_id, userId, delta);
          await ChallengeService.checkAndCompleteChallenge(inv.invite_id); 
        }
      }

      const joined = await TournamentModel.getJoinedTournamentsByUser(userId);
      for (const t of joined) {
        const pattern = norm(t.target_exercise_pattern || '');
        let delta = 0;

        for (const [exerciseName, reps] of Object.entries(repsByName)) {
          if (exerciseName.includes(pattern)) {
            delta += reps;
          }
        }

        if (delta > 0) {
          await TournamentModel.incrementTournamentProgress(t.tournament_id, userId, delta);
        }
      }

      return sessionId;
    } catch (error) {
      throw error;
    }
  }

  static async getUserWorkoutSessions(userId) {
    try {
      const sessions = await WorkoutSessionModel.getSessionsByUserId(userId);
      for (const session of sessions) {
        session.exercises = await ExerciseLogsModel.getExerciseLogsBySessionId(session.session_id);
      }
      return sessions;
    } catch (error) {
      throw error;
    }
  }

  static async getTodayCaloriesSummary(userId) {
    try {
      const summary = await WorkoutSessionModel.getTodayCaloriesSummaryByUserId(userId);
      return {
        totalCalories: summary.total_calories,
        firstStartTime: summary.first_start_time, // may be null if no sessions today
      };
    } catch (err) {
      throw err;
    }
  }

  static async getTodayCalories(userId) {
    try {
      return await WorkoutSessionModel.getTodayCaloriesByUserId(userId);
    } catch (err) {
      throw err;
    }
  }

  static async getDailyCaloriesSummary(userId, fromDate, toDate) {
    const rows = await WorkoutSessionModel.getDailyCaloriesByUserIdInRange(
      userId,
      fromDate,
      toDate
    );
    // Normalize numbers
    return rows.map(r => ({
      date: typeof r.day === 'string' ? r.day : new Date(r.day).toISOString().slice(0, 10),
      totalCalories: Number(r.total_calories || 0),
    }));
  }

  static async getHourlyCaloriesForDate(userId, ymd) {
    const rows = await WorkoutSessionModel.getHourlyCaloriesByUserAndDate(userId, ymd);
    const hourly = Array(24).fill(0);
    for (const r of rows) {
      const h = Number(r.hour);
      if (h >= 0 && h <= 23) {
        hourly[h] = Number(r.calories || 0);
      }
    }
    return { date: ymd, hourly };
  }
  static async getSessionIntensity(sessionId) {
    return await WorkoutSessionModel.getSessionIntensity(sessionId);
  }  
}

module.exports = WorkoutSessionService;
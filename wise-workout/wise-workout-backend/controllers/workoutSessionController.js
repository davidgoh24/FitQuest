const WorkoutSessionService = require('../services/workoutSessionService');

exports.saveWorkoutSession = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const { workoutId, startTime, endTime, duration, caloriesBurned, notes, exercises } = req.body;
    
    const sessionData = {
      userId,
      workoutId: workoutId || null,
      startTime: startTime || new Date().toISOString(),
      endTime: endTime || new Date().toISOString(),
      duration: duration || 0,
      caloriesBurned: caloriesBurned || 0,
      notes: notes || ''
    };

    const sessionId = await WorkoutSessionService.saveWorkoutSession(sessionData, exercises || []);
    
    res.status(201).json({ 
      message: 'Workout session saved successfully',
      sessionId 
    });
  } catch (error) {
    console.error('Error saving workout session:', error);
    res.status(500).json({ message: 'Failed to save workout session' });
  }
};

exports.getUserWorkoutSessions = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const sessions = await WorkoutSessionService.getUserWorkoutSessions(userId);
    
    res.json(sessions);
  } catch (error) {
    console.error('Error fetching workout sessions:', error);
    res.status(500).json({ message: 'Failed to fetch workout sessions' });
  }
};

exports.getTodayCaloriesSummary = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const { totalCalories, firstStartTime } =
      await WorkoutSessionService.getTodayCaloriesSummary(userId);

    return res.json({
      totalCalories,           // number
      firstStartTime,          // ISO string or null
    });
  } catch (err) {
    console.error('getTodayCaloriesSummary error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

exports.getDailyCaloriesSummaryRange = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    let { from, to } = req.query;
    if (!from || !to) {
      return res.status(400).json({ message: "Query params 'from' and 'to' are required (YYYY-MM-DD)" });
    }

    // Normalize to 'YYYY-MM-DD'
    const norm = (d) => {
      const dt = new Date(d);
      if (isNaN(dt.getTime())) throw new Error('Invalid date: ' + d);
      return dt.toISOString().slice(0, 10);
    };
    from = norm(from);
    to = norm(to);

    const days = await WorkoutSessionService.getDailyCaloriesSummary(userId, from, to);

    // Note: SQL returns only days that have data.
    // Frontend can fill missing dates with 0 to match the selected week.
    res.json({ from, to, days });
  } catch (err) {
    console.error('getDailyCaloriesSummaryRange error:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

exports.getHourlyCaloriesForDate = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    let { date } = req.query; // 'YYYY-MM-DD'
    if (!date) {
      return res.status(400).json({ message: "Query param 'date' is required (YYYY-MM-DD)" });
    }

    const dt = new Date(date);
    if (isNaN(dt.getTime())) {
      return res.status(400).json({ message: 'Invalid date' });
    }
    date = dt.toISOString().slice(0, 10);

    const result = await WorkoutSessionService.getHourlyCaloriesForDate(userId, date);
    res.json(result); // { date, hourly: [24 numbers] }
  } catch (err) {
    console.error('getHourlyCaloriesForDate error:', err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};
exports.getSessionIntensity = async (req, res) => {
  try {
    const { id } = req.params;
    if (!id) return res.status(400).json({ message: 'Session ID required' });

    const intensity = await WorkoutSessionService.getSessionIntensity(id);
    if (!intensity) return res.status(404).json({ message: 'Intensity not found' });

    res.json({ intensity });
  } catch (err) {
    console.error('Error fetching intensity:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

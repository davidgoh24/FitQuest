const UserPreferencesService = require('../services/userPreferencesService');

const submitUserPreferences = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const {
      dob,
      height_cm,
      weight_kg,
      gender,
      workout_days,
      workout_time,
      equipment_pref,
      fitness_goal,
      fitness_level,
      injury,
      enjoyed_workouts,
      bmi_value
    } = req.body;

    const requiredFields = {
      dob,
      height_cm,
      weight_kg,
      gender,
      workout_time,
      equipment_pref,
      fitness_goal,
      fitness_level,
      bmi_value
    };

    const missingFields = Object.entries(requiredFields)
      .filter(([key, value]) => value === undefined || value === null || value === '')
      .map(([key]) => key);

    if (missingFields.length > 0) {
      return res.status(400).json({
        message: `Missing required fields: ${missingFields.join(', ')}`
      });
    }

    const preferences = {
      height_cm,
      weight_kg,
      gender,
      workout_days,
      workout_time,
      equipment_pref,
      fitness_goal,
      fitness_level,
      injury,
      enjoyed_workouts, 
      bmi_value
    };

    await UserPreferencesService.submit(userId, preferences, dob);
    res.status(200).json({ message: 'Preferences submitted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

const checkPreferences = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });
    const hasPreferences = await UserPreferencesService.check(userId);
    res.status(200).json({ hasPreferences });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

const updatePreferences = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: 'Unauthorized' });

    const prefs = req.body;

    await UserPreferencesService.update(userId, prefs);

    res.status(200).json({ message: 'Preferences updated successfully' });
  } catch (err) {
    console.error("Update preferences error:", err);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

const getUserPreferences = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: "Unauthorized" });

    const prefs = await UserPreferencesService.getPreferences(userId);
    if (!prefs) return res.status(404).json({ message: "Preferences not found" });

    res.json({ preferences: prefs });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Add this export:
module.exports = {
  submitUserPreferences,
  checkPreferences,
  updatePreferences,
  getUserPreferences
};

//module.exports = { submitUserPreferences, checkPreferences };

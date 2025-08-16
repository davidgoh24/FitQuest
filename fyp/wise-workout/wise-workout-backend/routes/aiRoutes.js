const express = require('express');
const axios = require('axios');
const router = express.Router();
const UserPreferencesModel = require('../models/userPreferencesModel');
const ExerciseModel = require('../models/exerciseModel'); 

const OPENROUTER_KEY = "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";

router.post('/ai/fitness-plan', async (req, res) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ message: "Unauthorized" });

  try {
    const prefs = await UserPreferencesModel.getPreferences(userId);
    if (!prefs) return res.status(404).json({ message: "Preferences not found" });

    const exercises = await ExerciseModel.getAllExercises();
    if (!exercises || exercises.length === 0) {
      return res.status(404).json({ message: "No exercises found" });
    }

const systemPrompt = `
You are an expert fitness coach. Create a personalized 30-day workout plan based ONLY on the user's preferences and the provided exercise list, and include a concise progress estimation.

STRICT RULES FOR THE PLAN:
- Use only the exercises from the provided list. Never invent or use exercises not in the list.
- For each day, the number of exercises must match the user's "workout_time" preference:
  - If "Quick (e.g. 5 Minutes during Lunch Break)" → include only 1 exercise for that day.
  - If "Short (10-20 Minutes)" → include 2 exercises.
  - If "Medium (25-45 Minutes)" → include 4 exercises.
  - If "Long (1 Hour or more)" → include 6 exercises.
- Each day includes:
  - "day_of_month": 1 to 30 (incrementing)
  - "exercises": array of the correct number of exercises, each as { "name": "...", "sets": X, "reps": "..." }
  - "notes": short, motivating message (optional).
- Use rest days when appropriate: { "day_of_month": <n>, "rest": true, "notes": "..." }.
- Match equipment, goal, and level; avoid exercises conflicting with injuries.
- Prioritize exercises the user enjoys.
- For sets/reps, use numbers or clear text (e.g., "12", "10 per leg").

ESTIMATION & EXPLANATION ("estimation_text"):
- Summarize expected progress over 30 days assuming ~85–90% adherence.
- Cover fat/weight-loss potential, endurance/cardio, strength/muscle, mobility/flexibility.
- 3–6 bullet points + a 1–2 sentence wrap-up.
- Include a brief note that results vary with nutrition, sleep, and consistency. No medical claims.

OUTPUT FORMAT (IMPORTANT):
Output ONLY a valid JSON object with exactly these top-level keys:
{
  "plan": [ 31 items exactly — first = { "plan_title": "..." }, followed by the 30 day objects ],
  "estimation_text": "string containing bullets and a short wrap-up"
}
No markdown, comments, or extra keys.
`;

    const userPrompt = `
User preferences:
${JSON.stringify(prefs, null, 2)}

Available exercises (use only these!):
${JSON.stringify(exercises, null, 2)}
`;

    const response = await axios.post(
      'https://openrouter.ai/api/v1/chat/completions',
      {
        model: "moonshotai/kimi-k2:free",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt }
        ]
      },
      {
        headers: {
          "Authorization": `Bearer ${OPENROUTER_KEY}`,
          "Content-Type": "application/json"
        }
      }
    );

    console.log("AI response content:", response.data?.choices?.[0]?.message?.content);
    let raw = response.data?.choices?.[0]?.message?.content;
    let result;
    try {
      result = JSON.parse(raw);
    } catch (e) {
      // If the model returned invalid JSON, bail out clearly
      return res.status(502).json({ error: "AI returned non-JSON content" });
    }

    // Normalize: if model still returns an array, wrap it and add a basic estimation.
    if (Array.isArray(result)) {
      result = {
        plan: result,
        estimation_text: buildFallbackEstimationText(result, prefs)
      };
    }

    // Validate minimal structure
    if (!result || !Array.isArray(result.plan) || typeof result.estimation_text !== 'string') {
      return res.status(502).json({ error: "AI returned unexpected shape" });
    }

    return res.json({
      plan: result.plan,
      estimation_text: result.estimation_text,
      preferences: prefs,
      exercises
    });

    res.json({
      ai: response.data,
      preferences: prefs,
      exercises: exercises
    });

  } catch (error) {
    console.error("AI API error:", error?.response?.data || error.message);
    res.status(500).json({ error: "Failed to get AI fitness plan" });
  }
});

module.exports = router;

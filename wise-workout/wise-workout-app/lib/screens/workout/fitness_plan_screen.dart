import 'package:flutter/material.dart';
import '../../services/fitnessai_service.dart';
import '../edit_preferences_screen.dart';
import '../model/workout_day_model.dart';
import '../model/exercise_model.dart';
import 'ai_workout_plan_screen.dart';

class FitnessPlanScreen extends StatefulWidget {
  const FitnessPlanScreen({Key? key}) : super(key: key);

  @override
  State<FitnessPlanScreen> createState() => _FitnessPlanScreenState();
}

class _FitnessPlanScreenState extends State<FitnessPlanScreen> {
  final AIFitnessPlanService _aiService = AIFitnessPlanService();

  bool _loading = false;            // used for saving and for quick fetches
  bool _generatingPlan = false;     // used for "Generate AI Fitness Plan"
  bool _isPlanSaved = false;

  List<dynamic>? _plan;             // current plan preview on this page
  Map<String, dynamic>? _preferences;
  String? _estimationText;          // AI estimation/explanation
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  // -------------------- Helpers --------------------

  /// Normalizes whatever the service returns into the list structure
  /// your editor expects: [ {plan_title: ...}, day1, day2, ... ].
  List<dynamic> _normalizeFetchedPlan(dynamic fetchedPlan) {
    if (fetchedPlan == null) return <dynamic>[];
    if (fetchedPlan is List) return fetchedPlan;
    if (fetchedPlan is Map) return <dynamic>[fetchedPlan];
    return <dynamic>[];
  }

  /// Build an estimation/explanation from the plan + user prefs (fallback).
  String _buildEstimationFromPlan({
    required List<dynamic> planList,
    required Map<String, dynamic>? prefs,
  }) {
    if (planList.isEmpty) return '';

    // Skip title object if present
    final days = (planList.isNotEmpty && planList[0] is Map && planList[0]['plan_title'] != null)
        ? planList.sublist(1)
        : planList;

    int activeDays = 0, totalExercises = 0, totalSets = 0, totalReps = 0;
    for (final d in days) {
      final isRest = (d is Map && (d['rest'] == true));
      if (isRest) continue;
      activeDays++;
      final exs = (d is Map && d['exercises'] is List) ? (d['exercises'] as List) : const [];
      totalExercises += exs.length;
      for (final e in exs) {
        final sets = (e is Map && e['sets'] != null) ? int.tryParse(e['sets'].toString()) ?? 0 : 0;
        totalSets += sets;
        final repsStr = (e is Map && e['reps'] != null) ? e['reps'].toString() : '0';
        final repsNum = int.tryParse(RegExp(r'\d+').stringMatch(repsStr) ?? '0') ?? 0;
        totalReps += repsNum * sets;
      }
    }

    final goal = prefs?['fitness_goal']?.toString().toLowerCase() ?? '';
    final level = prefs?['fitness_level']?.toString() ?? '';

    final avgExercisesPerActiveDay = activeDays == 0 ? 0 : (totalExercises / activeDays);
    final avgSetsPerActiveDay     = activeDays == 0 ? 0 : (totalSets / activeDays);
    final avgRepsPerActiveDay     = activeDays == 0 ? 0 : (totalReps / activeDays);

    String headline;
    if (goal.contains('lose') || goal.contains('fat')) {
      headline = 'Projected fat-loss & conditioning gains';
    } else if (goal.contains('muscle') || goal.contains('strength')) {
      headline = 'Projected strength & muscle improvements';
    } else if (goal.contains('endurance') || goal.contains('stamina') || goal.contains('cardio')) {
      headline = 'Projected endurance and cardio benefits';
    } else if (goal.contains('flexib')) {
      headline = 'Projected mobility & flexibility gains';
    } else {
      headline = 'Projected fitness improvements over 30 days';
    }

    String intensity;
    if (avgExercisesPerActiveDay >= 5 || avgSetsPerActiveDay >= 12) {
      intensity = 'high';
    } else if (avgExercisesPerActiveDay >= 3 || avgSetsPerActiveDay >= 8) {
      intensity = 'moderate';
    } else {
      intensity = 'light';
    }

    final bullets = '''
• Schedule & volume: ~$activeDays active days in 30, ~${avgExercisesPerActiveDay.toStringAsFixed(1)} exercises/day.
• Estimated workload: ~${avgSetsPerActiveDay.toStringAsFixed(1)} sets/day, ~${avgRepsPerActiveDay.toStringAsFixed(0)} total reps/day → $intensity intensity for a $level level.
• Expectation window (adherence matters):
  – Weeks 1–2: skill learning, joint prep, neural adaptations.
  – Weeks 3–4: visible improvements in ${goal.isEmpty ? 'overall fitness' : goal}.
• Recovery guidance: keep 1–2 rest days/week; sleep 7–9h; protein 1.6–2.2 g/kg for muscle goals; hydration 30–35 ml/kg.
''';

    String outcome;
    if (goal.contains('lose') || goal.contains('fat')) {
      outcome = 'With ~90% adherence and a mild calorie deficit, expect modest fat loss (~0.3–0.7 kg/week) and better conditioning.';
    } else if (goal.contains('muscle') || goal.contains('strength')) {
      outcome = 'With adequate protein and progressive overload, expect beginner‑friendly strength gains and early hypertrophy signs.';
    } else if (goal.contains('endurance') || goal.contains('cardio')) {
      outcome = 'Expect measurable cardio improvements (lower RPE at same pace, longer work capacity) and better between‑set recovery.';
    } else if (goal.contains('flexib')) {
      outcome = 'Expect smoother range of motion, improved posture, and better movement control across key patterns.';
    } else {
      outcome = 'Expect steady improvements in capacity, form, and recovery across push/pull/legs and core.';
    }

    return '$headline\n\n$bullets\n$outcome\n\n*Note:* Results vary with nutrition, sleep, and consistency.';
  }

  // -------------------- Data loads --------------------

  Future<void> _fetchPreferences() async {
    setState(() {
      _loading = true;
      _preferences = null;
      _plan = null;
      _estimationText = null;
      _error = null;
    });

    try {
      final prefs = await _aiService.fetchPreferencesOnly();
      setState(() => _preferences = prefs);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Generate a brand new plan via AI (preview only) and show estimation.
  Future<void> _fetchPlan() async {
    setState(() {
      _generatingPlan = true;
      _plan = null;
      _estimationText = null;
      _error = null;
    });

    try {
      final result = await _aiService.fetchPlanFromDB();
      final fetchedPlan = result['plan'];
      final prefs = result['preferences'] ?? _preferences;

      final normalized = _normalizeFetchedPlan(fetchedPlan);
      setState(() {
        _plan = normalized;
        _estimationText = (result['estimation_text'] as String?)
            ?? _buildEstimationFromPlan(planList: normalized, prefs: prefs);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _generatingPlan = false);
    }
  }

  /// Fetch the latest saved plan and jump straight into the editor.
  Future<void> _editSavedPlan() async {
    setState(() => _loading = true);
    try {
      final result = await _aiService.fetchLatestSavedPlan();
      final planList = (result['plan'] as List?) ?? [];
      final savedEst = result['estimationText']?.toString();

      if (planList.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved plan found.')),
        );
        return;
      }

      setState(() => _estimationText = savedEst);

      if (!mounted) return;
      print(planList);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkoutPlanScreen(plan: planList)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load saved plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------- Small UI pieces --------------------

  Widget _estimationCard() {
    if (_estimationText == null || _estimationText!.trim().isEmpty) return const SizedBox();
    return Card(
      elevation: 3,
      color: Colors.teal.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estimation & Explanation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              _estimationText!,
              style: const TextStyle(fontSize: 14.5, height: 1.35, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreferencesCard() {
    if (_preferences == null) return const SizedBox();
    return Card(
      elevation: 3,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Your Fitness Preferences",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: "Edit Preferences",
                  onPressed: () async {
                    final updatedPrefs = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPreferencesScreen(
                          preferences: Map<String, dynamic>.from(_preferences!),
                        ),
                      ),
                    );
                    if (updatedPrefs != null) {
                      setState(() {
                        _preferences = updatedPrefs;
                        _plan = null;
                        _estimationText = null;
                      });
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            ..._preferences!.entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  "${_preferenceLabel(e.key)}: ${e.value ?? '-'}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _preferenceLabel(String key) {
    switch (key) {
      case 'fitness_goal':
        return 'Goal';
      case 'fitness_level':
        return 'Level';
      case 'workout_days':
        return 'Workout Days';
      case 'workout_time':
        return 'Workout Time';
      case 'equipment_pref':
        return 'Equipment';
      case 'weight_kg':
        return 'Weight (kg)';
      case 'height_cm':
        return 'Height (cm)';
      case 'gender':
        return 'Gender';
      case 'injury':
        return 'Injury';
      case 'enjoyed_workouts':
        return 'Enjoyed Workouts';
      case 'bmi_value':
        return 'BMI';
      default:
        return key;
    }
  }

  /// Non‑scrollable list (so it fits inside the outer SingleChildScrollView)
  Widget buildPlanList() {
    if (_plan == null || _plan!.isEmpty) {
      return const Text(
        "No plan found. Please complete your fitness profile and try again.",
        style: TextStyle(color: Colors.grey),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _plan!.length - 1,
      itemBuilder: (context, idx) {
        final dayPlan = _plan![idx + 1];
        final isRest = dayPlan['rest'] == true;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayPlan['day_of_month'] != null
                      ? "Day ${dayPlan['day_of_month']}"
                      : (dayPlan['day_of_week'] ?? (dayPlan['day'] != null ? "Day ${dayPlan['day']}" : '-')),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 6),
                if (isRest) ...[
                  const Text(
                    "Rest Day",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                ] else ...[
                  ...((dayPlan['exercises'] ?? []).map<Widget>((ex) {
                    final name = ex['name'] ?? '';
                    final sets = ex['sets']?.toString() ?? '-';
                    final reps = ex['reps']?.toString() ?? '-';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        '$name  |  Sets: $sets  |  Reps: $reps',
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList()),
                ],
                if (dayPlan['notes'] != null && dayPlan['notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Notes: ${dayPlan['notes']}",
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildGeneratePlanButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      child: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.bolt, color: Colors.black54),
          label: const Text(
            "Generate AI Fitness Plan",
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _generatingPlan ? null : _fetchPlan,
        ),
      ),
    );
  }

  Widget _buildEditSavedPlanButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.green),
          label: const Text(
            "Edit Saved Plan",
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _loading ? null : _editSavedPlan,
        ),
      ),
    );
  }

  // -------------------- Build --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Fitness Plan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: "Edit Saved Plan",
            onPressed: _loading ? null : _editSavedPlan,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Preferences",
            onPressed: _preferences == null
                ? null
                : () async {
              final updatedPrefs = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPreferencesScreen(
                    preferences: Map<String, dynamic>.from(_preferences!),
                  ),
                ),
              );
              if (updatedPrefs != null) {
                setState(() {
                  _preferences = updatedPrefs;
                  _plan = null;
                  _estimationText = null;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: "View Calendar",
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_preferences != null) buildPreferencesCard(),

              _buildEditSavedPlanButton(),

              if (_preferences != null && (_plan == null || _plan!.isEmpty))
                buildGeneratePlanButton(),

              if (_plan != null && _plan!.isNotEmpty) ...[
                Text(
                  _plan![0]['plan_title'] ?? 'Personalized Plan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.teal,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Estimation card scrolls with the page
                _estimationCard(),

                // Save + Edit buttons for the previewed plan
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save This Plan'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: (_plan == null || _plan!.isEmpty)
                              ? null
                              : () async {
                            setState(() => _loading = true);
                            try {
                              final String planTitle = _plan![0]['plan_title'];
                              final List<dynamic> planDaysJson = _plan!.sublist(1);

                              final List<WorkoutDay> workoutDays = planDaysJson.map<WorkoutDay>((dayJson) {
                                final exercises = (dayJson['exercises'] as List?)
                                    ?.map<Exercise>((e) => Exercise.fromAiJson(e))
                                    .toList() ??
                                    [];
                                return WorkoutDay(
                                  dayOfMonth: dayJson['day_of_month'],
                                  exercises: exercises,
                                  notes: dayJson['notes'] ?? '',
                                  isRest: dayJson['rest'] ?? false,
                                );
                              }).toList();

                              await _aiService.savePlanToBackend(
                                planTitle,
                                workoutDays,
                                estimationText: _estimationText,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Plan saved successfully!')),
                              );

                              setState(() {
                                _isPlanSaved = true;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            } finally {
                              setState(() => _loading = false);
                            }
                          },
                        ),
                        if (_isPlanSaved) ...[
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Plan'),
                            onPressed: _loading ? null : () async => _editSavedPlan(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Day list — non‑scrollable, sits inside the page scroll
                buildPlanList(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

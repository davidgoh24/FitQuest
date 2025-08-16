import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/workout_service.dart';
import '../../services/workout_session_service.dart';
import '../../services/health_service.dart';

class WorkoutAnalysisPage extends StatefulWidget {
  const WorkoutAnalysisPage({super.key});

  @override
  State<WorkoutAnalysisPage> createState() => _WorkoutAnalysisPageState();
}

class _WorkoutAnalysisPageState extends State<WorkoutAnalysisPage> {
  String formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
  }
  late final TextEditingController _notesController;

  DateTime _workoutStartTime = DateTime.now();
  bool _hasSaved = false;

  int? avgHeartRate;
  int? peakHeartRate;
  bool _isHeartRateLoading = true;

  @override
  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(); // <-- add this
    _workoutStartTime = DateTime.now().subtract(
      Duration(seconds: WorkoutSessionService().elapsed.inSeconds),
    );
    _fetchHeartRate();
  }


  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSaved) {
      _hasSaved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _saveWorkoutSession();
      });
    }
  }

  void _fetchHeartRate() async {
    setState(() => _isHeartRateLoading = true);
    final start = _workoutStartTime;
    final end = DateTime.now();
    final healthService = HealthService();

    try {
      final heartRatePoints =
      await healthService.getHeartRateDataInRange(start, end);

      if (heartRatePoints.isNotEmpty) {
        final values = heartRatePoints
            .map((e) => (e.value as num).toDouble())
            .toList();
        final avg = (values.reduce((a, b) => a + b) / values.length).round();
        final peak = values.reduce((a, b) => a > b ? a : b).round();
        setState(() {
          avgHeartRate = avg;
          peakHeartRate = peak;
          _isHeartRateLoading = false;
        });
      } else {
        setState(() {
          avgHeartRate = null;
          peakHeartRate = null;
          _isHeartRateLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        avgHeartRate = null;
        peakHeartRate = null;
        _isHeartRateLoading = false;
      });
    }
  }

  double calculateTotalCalories(List exercises) {
    double totalCalories = 0.0;
    for (var exercise in exercises) {
      final sets = (exercise['sets'] as List?) ?? [];
      final caloriesPerRep =
          (exercise['calories_burnt_per_rep'] as num?)?.toDouble() ?? 0.0;
      final totalReps = sets.fold<int>(
        0,
            (sum, set) => sum + (set['reps'] as int? ?? 0),
      );
      totalCalories += totalReps * caloriesPerRep;
    }
    return totalCalories;
  }

  Future<void> _saveWorkoutSession({String? notes}) async {
    try {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final Map<String, dynamic> workout = args['workout'];
      final List exercises = args['exercises'];
      final Duration duration = args['duration'];

      final workoutService = WorkoutService();
      final double calories = calculateTotalCalories(exercises);

      final List<Map<String, dynamic>> formattedExercises =
      exercises.map((exercise) {
        return {
          'exerciseKey': exercise['exerciseKey'] ??
              exercise['exercise_name']
                  ?.toString()
                  .toLowerCase()
                  .replaceAll(' ', '_'),
          'exerciseName':
          exercise['exerciseName'] ?? exercise['exercise_name'],
          'setsData': exercise['sets'] ?? [],
          'calories_burnt_per_rep': exercise['calories_burnt_per_rep'],
        };
      }).toList();

      await workoutService.saveWorkoutSession(
        workoutId: workout['workoutId'],
        startTime: _workoutStartTime,
        endTime: DateTime.now(),
        duration: duration.inSeconds,
        caloriesBurned: calories,
        exercises: formattedExercises,
        notes: notes, // <-- NEW field for backend
      );

      if (mounted && notes != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save workout: $e')),
        );
      }
    }
  }

  String buildShareContent({
    required String workoutName,
    required String date,
    required String duration,
    required String calories,
    required String intensity,
    required int avgHeartRate,
    required int peakHeartRate,
    required int totalSets,
    required String maxWeight,
    required String caloriesPerMin,
    String? notes,
  }) {
    String statString = [
      "Average Heart Rate: $avgHeartRate bpm",
      "Peak Heart Rate: $peakHeartRate bpm",
      "Sets: $totalSets",
      "Max Weight: $maxWeight",
      "Calories per min: $caloriesPerMin",
    ].join('\n');

    String text = "🏋️ Workout: $workoutName\n"
        "📅 Date: $date\n"
        "⏱ Duration: $duration\n"
        "🔥 Calories: $calories\n"
        "⬆️ Intensity: $intensity\n"
        "$statString";

    if (notes != null && notes.trim().isNotEmpty) {
      text += "\n📝 Notes: $notes";
    }
    text += "\n\nShared via MyWorkoutApp 💪";
    return text;
  }

  void _showShareEditDialog(BuildContext context, String initialText) {
    final controller = TextEditingController(text: initialText);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final padding = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit your share message',
                style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  minLines: 4,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: Icon(Icons.share, color: colorScheme.onPrimary),
                    label: Text(
                      "Share",
                      style: textTheme.labelLarge
                          ?.copyWith(color: colorScheme.onPrimary),
                    ),
                    onPressed: () {
                      final msg = controller.text.trim();
                      if (msg.isNotEmpty) {
                        Share.share(msg, subject: "My Workout Accomplishment!");
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Map<String, dynamic> workout = args['workout'];
    final List exercises = args['exercises'];
    final Duration duration = args['duration'];

    final double calories = calculateTotalCalories(exercises);

    final int totalReps = exercises
        .expand((e) => ((e['sets'] as List?) ?? [])
        .map((s) => s['reps'] as int? ?? 0))
        .fold(0, (sum, r) => sum + r);

    final int totalSets = exercises.fold(
      0,
          (sum, e) => sum + (((e['sets'] as List?) ?? []).length),
    );

    final double maxWeight = exercises
        .expand((e) => ((e['sets'] as List?) ?? []))
        .map((s) => s['weight'])
        .whereType<num>()
        .fold<num>(0.0, (prev, w) => w > prev ? w : prev)
        .toDouble();

    final sessionNotes = 'Felt strong! Increased weight 😎';
    final double durationInMinutes = duration.inSeconds / 60.0;
    final double caloriesPerMin =
    (durationInMinutes >= 1) ? (calories / durationInMinutes) : 0.0;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: colorScheme.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Workout Analysis',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary,
                    child:
                    Icon(Icons.fitness_center, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout['workoutName'] ?? 'Workout',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateTime.now().toIso8601String().substring(0, 10),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryCard(
                      context, Icons.timer, '${formatDuration(duration)}', 'Duration'),
                  _summaryCard(context, Icons.local_fire_department,
                      '${calories.toStringAsFixed(0)} kcal', 'Calories'),
                  _summaryCard(context, Icons.fitness_center, 'Advanced',
                      'Intensity'),
                ],
              ),
              const SizedBox(height: 24),

              _statsSection(context, [
                _statRow(
                  context,
                  'Average Heart Rate',
                  _isHeartRateLoading
                      ? 'Loading...'
                      : (avgHeartRate != null ? '$avgHeartRate bpm' : 'N/A'),
                ),
                _statRow(
                  context,
                  'Peak Heart Rate',
                  _isHeartRateLoading
                      ? 'Loading...'
                      : (peakHeartRate != null ? '$peakHeartRate bpm' : 'N/A'),
                ),
                _statRow(context, 'Sets', '$totalSets'),
                _statRow(context, 'Total Reps', totalReps.toString()),
                _statRow(context, 'Max Weight',
                    '${maxWeight.toStringAsFixed(1)} kg'),
                _statRow(context, 'Calories per min',
                    caloriesPerMin.toStringAsFixed(2)),
              ]),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Session Notes',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // NEW: Editable notes field
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Notes"),
                onPressed: () {
                  final userNotes = _notesController.text.trim();
                  if (userNotes.isNotEmpty) {
                    _saveWorkoutSession(notes: userNotes);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter notes')),
                    );
                  }
                },
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Exercises Performed',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, i) {
                    final e = exercises[i];
                    final sets = (e['sets'] as List?) ?? [];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: colorScheme.surface,
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          e['exerciseName'] ?? e['exercise_name'] ?? 'Exercise',
                          style: textTheme.titleSmall,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sets.map<Widget>((s) {
                            final setNo = s['set'] ?? '';
                            final reps = s['reps'] ?? 0;
                            final weight = s['weight'] ?? 0;
                            return Text(
                              'Set $setNo: $reps reps @ $weight kg',
                              style: textTheme.bodyMedium,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    final workoutName = workout['workoutName'] ?? 'Workout';
                    final date =
                    DateTime.now().toIso8601String().substring(0, 10);
                    final initialText = buildShareContent(
                      workoutName: workoutName,
                      date: date,
                      duration: formatDuration(duration),
                      calories: '${calories.toStringAsFixed(0)} kcal',
                      intensity: 'Advanced',
                      avgHeartRate: avgHeartRate ?? 0,
                      peakHeartRate: peakHeartRate ?? 0,
                      totalSets: totalSets,
                      maxWeight: '${maxWeight.toStringAsFixed(1)} kg',
                      caloriesPerMin: caloriesPerMin.toStringAsFixed(1),
                      notes: sessionNotes,
                    );
                    _showShareEditDialog(context, initialText);
                  },
                  icon: Icon(Icons.share, color: colorScheme.onPrimary),
                  label: Text(
                    'Share',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
      BuildContext context, IconData icon, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 32, color: colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }

  Widget _statsSection(BuildContext context, List<Widget> children) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detailed Stats',
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
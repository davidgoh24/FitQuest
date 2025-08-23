import 'dart:async';
import 'package:flutter/material.dart';
import '../model/exercise_model.dart';
import '../../services/exercise_service.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/exercise_tile.dart';
import 'congratulation_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ExerciseListPage extends StatefulWidget {
  final int workoutId;
  final String workoutName;

  const ExerciseListPage({
    super.key,
    required this.workoutId,
    required this.workoutName,
  });

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  late Future<List<Exercise>> _exercisesFuture;
  final WorkoutSessionService _sessionService = WorkoutSessionService();

  String _formattedTime = "00:00:00";
  late StreamSubscription<Duration> _elapsedSubscription;

  @override
  void initState() {
    super.initState();
    _exercisesFuture =
        ExerciseService().fetchExercisesByWorkout(widget.workoutId.toString());
    _elapsedSubscription =
        _sessionService.elapsedStream.listen((elapsed) {
          setState(() {
            _formattedTime = _formatDuration(elapsed);
          });
        });
    if (_sessionService.isActive) {
      _formattedTime = _formatDuration(_sessionService.elapsed);
    }
  }

  @override
  void dispose() {
    _elapsedSubscription.cancel();
    super.dispose();
  }

  void _startWorkout() {
    _sessionService.setWorkoutName(widget.workoutName);

    if (_sessionService.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('exercise_list_already_started'))),
      );
      return;
    }

    // 👇 Tell the overlay how to navigate back to THIS page
    _sessionService.setStartContext(
      '/exercise-list-page', // this matches your onGenerateRoute
      args: {
        'workoutId': widget.workoutId,
        'workoutName': widget.workoutName,
      },
    );

    _sessionService.start((_) {});
  }

  void _endWorkout() async {
    final duration = _sessionService.elapsed;
    final exercises = _sessionService.loggedExercises.map((exercise) {
        print('DEBUG: Exercise fetched - ${exercise['exerciseName']}, calories_burnt_per_rep: ${exercise['calories_burnt_per_rep']}');
      return {
        'exerciseId': exercise['exerciseId'],
        'exerciseKey': exercise['exerciseKey'],
        'exerciseName': exercise['exerciseName'],
        'calories_burnt_per_rep': exercise['calories_burnt_per_rep'],
        'sets': List<Map<String, dynamic>>.from(exercise['sets'].map((set) {
          return {
            'set': set['set'],
            'weight': set['weight'],
            'reps': set['reps'],
            'finished': set['finished'],
          };
        })),
      };
    }).toList();
    print('DEBUG: Exercises to be saved: $exercises');
    _sessionService.clearSession();
    setState(() {
      _formattedTime = "00:00:00";
    });
    final workoutResult = {
      'workout': {
        'workoutId': widget.workoutId,
        'workoutName': widget.workoutName,
      },
      'exercises': exercises,
      'duration': duration,
      'calories': _calculateCalories(exercises),
    };
    print('DEBUG: Workout result being passed: $workoutResult');
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CongratulationScreen(workoutResult: workoutResult),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  double _calculateCalories(List exercises) {
    double totalCalories = 0.0;
    for (var exercise in exercises) {
      final sets = exercise['sets'] as List? ?? [];
      final caloriesPerRep = (exercise['calories_burnt_per_rep'] as num?)?.toDouble() ?? 0.0;
      final totalReps = sets.fold<int>(0, (sum, set) => sum + (set['reps'] as int? ?? 0));
      totalCalories += totalReps * caloriesPerRep;
    }
    return totalCalories;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shadowColor = Theme.of(context).shadowColor;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Exercise>>(
            future: _exercisesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                );
              }
              if (snapshot.hasError) {
                final errorMsg = snapshot.error?.toString() ?? 'Unknown error';
                return Center(
                  child: Text(
                    '${tr('exercise_list_error')}: $errorMsg',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              }
              final exercises = snapshot.data!;
              final translated = tr('exercise_list_found');
              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 250,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/workoutImages/${widget.workoutName.toLowerCase().replaceAll(' ', '_')}.jpg',
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 16,
                            child: CircleAvatar(
                              backgroundColor:
                              colorScheme.surface.withOpacity(0.8),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back,
                                    color: colorScheme.onSurface),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Text(
                              widget.workoutName,
                              style: textTheme.headlineLarge?.copyWith(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exercises.length} $translated',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...exercises.map((exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ExerciseTile(
                          exercise: exercise,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/exercise-detail',
                              arguments: exercise,
                            );
                          },),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_sessionService.isActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(tr('exercise_list_end_title'),
                          style: textTheme.titleLarge),
                      content: Text(tr('exercise_list_end_confirm'),
                          style: textTheme.bodyLarge),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            tr('cancel'),
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            tr('end'),
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    _endWorkout();
                  }
                },
                icon: Icon(Icons.stop,
                    color: colorScheme.onPrimary),
                label: Text(
                  _formattedTime,
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onPrimary),
                ),
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
        ],
      ),
      floatingActionButton: !_sessionService.isActive
          ? FloatingActionButton.extended(
        onPressed: _startWorkout,
        icon: Icon(Icons.fitness_center,
            color: colorScheme.onPrimary),
        label: Text(
          tr('exercise_list_start'),
          style: textTheme.labelLarge
              ?.copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      )
          : null,
    );
  }
}
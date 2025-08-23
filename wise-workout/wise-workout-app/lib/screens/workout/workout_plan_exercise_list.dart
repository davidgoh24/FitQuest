import 'package:flutter/material.dart';
import '../model/exercise_model.dart';
import '../../services/exercise_service.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/exercise_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'congratulation_screen.dart';


class WorkoutPlanExerciseList extends StatefulWidget {
  final String planTitle;
  final List<String> exerciseNames;

  const WorkoutPlanExerciseList({
    super.key,
    required this.planTitle,
    required this.exerciseNames,
  });

  @override
  State<WorkoutPlanExerciseList> createState() => _WorkoutPlanExerciseListState();
}

class _WorkoutPlanExerciseListState extends State<WorkoutPlanExerciseList> {
  late Future<List<Exercise>> _exercisesFuture;
  final WorkoutSessionService _sessionService = WorkoutSessionService();

  String _formattedTime = "00:00:00";
  late StreamSubscription<Duration> _elapsedSubscription;
  bool _isSessionActive = false;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = ExerciseService().fetchExercisesByNames(widget.exerciseNames);

    _elapsedSubscription = _sessionService.elapsedStream.listen((elapsed) {
      setState(() {
        _formattedTime = _formatDuration(elapsed);
      });
    });

    _isSessionActive = _sessionService.isActive &&
        _sessionService.workoutName == widget.planTitle;

    if (_isSessionActive) {
      _formattedTime = _formatDuration(_sessionService.elapsed);
    }
  }

  @override
  void dispose() {
    _elapsedSubscription.cancel();
    super.dispose();
  }

  void _startWorkout() {
    _sessionService.setWorkoutName(widget.planTitle);

    if (_sessionService.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('exercise_list_already_started'))),
      );
      return;
    }

    _sessionService.start((_) {});
    setState(() {
      _isSessionActive = true;
      _isStopping = false;
    });
  }

  Future<void> _endWorkout() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);

    final duration = _sessionService.elapsed;
    final exercises = _sessionService.loggedExercises.map((exercise) {
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

    final workoutResult = {
      'workout': {
        'workoutId': null,
        'workoutName': widget.planTitle,
      },
      'exercises': exercises,
      'duration': duration,
      'calories': _calculateCalories(exercises),
    };

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('exercise_list_end_title')),
          content: Text(tr('exercise_list_end_confirm')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr('end')),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _sessionService.clearSession();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CongratulationScreen(workoutResult: workoutResult),
        ),
      );
    } else {
      setState(() => _isStopping = false);
    }
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

  Widget _buildTimerWithStopButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _isStopping ? null : _endWorkout,
            tooltip: tr('stop_workout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planTitle),
        centerTitle: true,
        actions: [
          if (_isSessionActive) _buildTimerWithStopButton(),
        ],
      ),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No exercises found in ${widget.planTitle}"));
          }
          final exercises = snapshot.data!;
          return ListView.separated(
            itemCount: exercises.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            padding: const EdgeInsets.all(18),
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return ExerciseTile(
                exercise: ex,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/exercise-detail',
                    arguments: ex,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: !_isSessionActive
          ? FloatingActionButton.extended(
        onPressed: _startWorkout,
        icon: Icon(Icons.fitness_center, color: colorScheme.onPrimary),
        label: Text(
          tr('exercise_list_start'),
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
      )
          : null,
    );
  }
}
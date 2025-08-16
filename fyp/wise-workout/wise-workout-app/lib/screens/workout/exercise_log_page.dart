import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:easy_localization/easy_localization.dart';
import '../model/exercise_model.dart';
import '../../widgets/exercise_timer.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/inline_exercise_timer.dart';

class ExerciseLogPage extends StatefulWidget {
  final Exercise exercise;
  const ExerciseLogPage({super.key, required this.exercise});
  @override
  State<ExerciseLogPage> createState() => _ExerciseLogPageState();
}

class _ExerciseLogPageState extends State<ExerciseLogPage> {
  List<Map<String, dynamic>> sets = [];
  final CountDownController _restTimerController = CountDownController();
  List<bool> isSetTiming = [];

  @override
  void initState() {
    super.initState();
    int numSets = widget.exercise.exerciseSets > 0 ? widget.exercise.exerciseSets : 0;
    sets = List.generate(numSets, (index) {
      return {
        'set': index + 1,
        'weight': widget.exercise.exerciseWeight ?? 0.0,
        'reps': widget.exercise.exerciseReps,
        'finished': false,
      };
    });
    isSetTiming = List.generate(numSets, (index) => false);
  }

  void _saveLogToSession() {
    List<Map<String, dynamic>> completedSets = sets.where((set) => set['finished'] == true).toList();
    if (completedSets.isEmpty) {
      completedSets = sets.where((set) => set['reps'] != null && set['reps'] > 0).toList();
      for (var set in completedSets) {
        set['finished'] = true;
      }
    }
    if (completedSets.isNotEmpty) {
      final exerciseLog = {
        'exerciseId': widget.exercise.exerciseId,
        'exerciseKey': widget.exercise.exerciseKey,
        'exerciseName': widget.exercise.exerciseName,
        'sets': completedSets,
        'calories_burnt_per_rep': widget.exercise.calories_burnt_per_rep ?? 0.0,
      };
      WorkoutSessionService().addExerciseLog(exerciseLog);
    }
  }

  void _addSet() {
    setState(() {
      sets.add({
        'set': sets.length + 1,
        'weight': widget.exercise.exerciseWeight ?? 0.0,
        'reps': widget.exercise.exerciseReps,
        'finished': false,
      });
      isSetTiming.add(false);
    });
  }

  void _editValue(int index, String key, dynamic value) {
    setState(() {
      sets[index][key] = value;
    });
  }

  @override
  void dispose() {
    _saveLogToSession();
    super.dispose();
  }

  Future<String?> _showEditDialog(String initial, String label) async {
    final controller = TextEditingController(text: initial);
    // Select-all so user can just type without deleting
    controller.selection = TextSelection(baseOffset: 0, extentOffset: initial.length);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'edit'.tr()} $label', style: textTheme.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true, // <— focus immediately
          keyboardType: TextInputType.number,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.outline)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('save'.tr(), style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface)),
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
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 280,
                child: Image.asset(
                  'assets/exerciseGif/${widget.exercise.exerciseName.replaceAll(' ', '_').toLowerCase()}.gif',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface.withOpacity(0.88),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  children: [
                    Center(child: Text('exercise_set'.tr(), style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                    Center(child: Text('exercise_weight'.tr(), style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                    Center(child: Text('exercise_reps'.tr(), style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                    Center(child: Text('exercise_action'.tr(), style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 1.5, color: colorScheme.outline),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: sets.isEmpty
                  ? Center(
                child: Text(
                  'No sets defined for this exercise.',
                  style: textTheme.bodyLarge,
                ),
              )
                  : Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  for (int index = 0; index < sets.length; index++)
                    TableRow(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              '${'exercise_set'.tr()} ${sets[index]['set']}',
                              style: textTheme.bodyLarge?.copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await _showEditDialog(
                                  sets[index]['weight'].toString(), 'exercise_weight'.tr());
                              if (result != null) _editValue(index, 'weight', double.tryParse(result) ?? 0.0);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                '${sets[index]['weight']} kg',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await _showEditDialog(
                                  sets[index]['reps'].toString(), 'exercise_reps'.tr());
                              if (result != null) _editValue(index, 'reps', int.tryParse(result) ?? 1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                '${sets[index]['reps']}',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            height: 40,
                            child: widget.exercise.exerciseDuration != null
                                ? (isSetTiming.length > index && isSetTiming[index])
                                ? Center(
                              child: InlineExerciseTimer(
                                duration: widget.exercise.exerciseDuration!,
                                onCompleted: () {
                                  setState(() {
                                    sets[index]['finished'] = true;
                                    isSetTiming[index] = false;
                                  });
                                },
                              ),
                            )
                                : Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: sets[index]['finished'] == true
                                      ? colorScheme.tertiary
                                      : colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  minimumSize: const Size(36, 36),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                ),
                                onPressed: sets[index]['finished'] == true
                                    ? null
                                    : () {
                                  setState(() {
                                    if (isSetTiming.length <= index) {
                                      isSetTiming.addAll(List.filled(index + 1 - isSetTiming.length, false));
                                    }
                                    isSetTiming[index] = true;
                                  });
                                },
                                child: Text(
                                  sets[index]['finished'] == true
                                      ? '✓'
                                      : 'start'.tr(),
                                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                                : Center(
                              child: IconButton(
                                icon: Icon(
                                  sets[index]['finished'] == true
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: sets[index]['finished'] == true
                                      ? colorScheme.tertiary
                                      : colorScheme.outline,
                                  size: 32,
                                ),
                                onPressed: sets[index]['finished'] == true
                                    ? null
                                    : () {
                                  setState(() => sets[index]['finished'] = true);
                                  ExerciseTimer.showRestTimer(context, _restTimerController);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: _addSet,
              child: Text('+ ${'exercise_add_set'.tr()}', style: textTheme.labelLarge),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              onPressed: () => ExerciseTimer.showRestTimer(context, _restTimerController),
              child: Text('exercise_rest_timer'.tr(), style: textTheme.labelLarge),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

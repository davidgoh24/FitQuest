import 'package:flutter/material.dart';
import '../../screens/model/exercise_model.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = colorScheme.primaryContainer;
    final textColor = colorScheme.onPrimaryContainer;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  _getExerciseImagePath(exercise.exerciseName),
                  width: 180,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 180,
                    height: 120,
                    color: backgroundColor,
                    child: Icon(Icons.image, color: textColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.exerciseSets} sets • ${exercise.exerciseReps} reps',
                      style: textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level: ${exercise.exerciseLevel ?? 'N/A'}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExerciseImagePath(String title) {
    final formatted = title.toLowerCase().replaceAll(' ', '_');
    return 'assets/exerciseImages/${formatted}_gif.png';
  }
}
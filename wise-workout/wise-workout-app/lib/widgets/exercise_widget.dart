import 'package:flutter/material.dart';
import '../screens/model/exercise_model.dart';

class ExerciseWidget extends StatelessWidget {
  final int dayOfMonth;
  final List<dynamic> exercises;
  final String notes;
  final bool isEditing;
  final VoidCallback? onAddExercise;
  final Function(int)? onDeleteExercise;

  const ExerciseWidget({
    Key? key,
    required this.dayOfMonth,
    required this.exercises,
    required this.notes,
    this.isEditing = false,
    this.onAddExercise,
    this.onDeleteExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day $dayOfMonth',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.teal),
                    onPressed: onAddExercise,
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Notes: $notes',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const Divider(),
            if (exercises.isEmpty && isEditing)
              Center(
                child: TextButton.icon(
                  onPressed: onAddExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              )
            else
              ...exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  color: Colors.grey[50],
                  child: ListTile(
                    title: Text(exercise['name']),
                    subtitle: Text('Sets: ${exercise['sets']}, Reps: ${exercise['reps']}'),
                    trailing: isEditing
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDeleteExercise?.call(index),
                    )
                        : null,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
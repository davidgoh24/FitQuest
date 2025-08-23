import 'package:flutter/material.dart';
import '../screens/model/workout_model.dart'; // <- adjust path as needed

class WorkoutTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const WorkoutTile({Key? key, required this.workout, required this.onTap})
      : super(key: key);

  String sanitizeFilename(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '') // remove punctuation
        .replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    final imagePath =
        'assets/workoutImages/${sanitizeFilename(workout.workoutName)}.jpg';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
          margin: EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 184,
                    height: 140,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          width: 184,
                          height: 140,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.workoutName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.workoutDescription,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '22 Minutes | ${workout.workoutLevel}', // Optional: add real duration field later
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

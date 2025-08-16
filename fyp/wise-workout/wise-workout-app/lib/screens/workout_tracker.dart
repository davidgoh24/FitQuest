import 'package:flutter/material.dart';
import '../widgets/workout_card.dart';

class WorkoutTracker extends StatelessWidget {
  final List<Map<String, String>> workoutHistory = [
    {"title": "Morning Run", "duration": "30 mins", "calories": "250"},
    {"title": "HIIT Session", "duration": "20 mins", "calories": "300"},
    {"title": "Evening Walk", "duration": "45 mins", "calories": "180"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Workout Tracker")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Today's Summary", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red, size: 30),
                        SizedBox(height: 4),
                        Text("Calories"),
                        Text("730 kcal", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.timer, color: Colors.blue, size: 30),
                        SizedBox(height: 4),
                        Text("Time"),
                        Text("95 mins", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.directions_walk, color: Colors.green, size: 30),
                        SizedBox(height: 4),
                        Text("Steps"),
                        Text("8500", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Recent Workouts", style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: workoutHistory.length,
                itemBuilder: (context, index) {
                  final item = workoutHistory[index];
                  return WorkoutCard(
                    title: item['title']!,
                    duration: item['duration']!,
                    calories: item['calories']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String duration;
  final String calories;

  const WorkoutCard({
    required this.title,
    required this.duration,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.fitness_center),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$duration | $calories kcal'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

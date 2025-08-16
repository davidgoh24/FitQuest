import 'package:flutter/material.dart';

class CompetitionCard extends StatelessWidget {
  final String opponentName;
  final String status;
  final VoidCallback onPressed;

  const CompetitionCard({
    required this.opponentName,
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.sports_kabaddi),
        title: Text(opponentName),
        subtitle: Text(status),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: Text("Challenge"),
        ),
      ),
    );
  }
}

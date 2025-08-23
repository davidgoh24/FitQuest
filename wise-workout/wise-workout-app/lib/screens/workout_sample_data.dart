class Workout {
  final String imagePath;
  final String workoutName;
  final String workoutLevel;

  const Workout({
    required this.imagePath,
    required this.workoutName,
    required this.workoutLevel,
  });
}

const List<Workout> sampleWorkouts = [
  Workout(
    imagePath: 'assets/images/push-up.jpg',
    workoutName: 'Push Ups',
    workoutLevel: 'Beginner Level',
  ),
  Workout(
    imagePath: 'assets/images/squats.jpg',
    workoutName: 'Squats',
    workoutLevel: 'Beginner Level',
  ),
  Workout(
    imagePath: 'assets/images/plank.jpg',
    workoutName: 'Plank',
    workoutLevel: 'Beginner Level',
  ),
  Workout(
    imagePath: 'assets/images/jumping_jacks.jpg',
    workoutName: 'Jumping Jacks',
    workoutLevel: 'Beginner Level',
  ),
];

class Tournament {
  final String tournamentName;
  final String prize;
  final String participants;
  final double progress;
  final String daysLeft;

  const Tournament({
    required this.tournamentName,
    required this.prize,
    required this.participants,
    required this.progress,
    required this.daysLeft,
  });
}

const List<Tournament> sampleTournaments = [
  Tournament(
    tournamentName: 'Summer Challenge',
    prize: '\$5,000',
    participants: '2.4k',
    progress: 0.65,
    daysLeft: '5 Days',
  ),
  Tournament(
    tournamentName: 'Plank Challenge',
    prize: 'Premium',
    participants: '1.8k',
    progress: 0.35,
    daysLeft: '12 Days',
  ),
  Tournament(
    tournamentName: 'Mountain Marathon',
    prize: '\$2,500',
    participants: '890',
    progress: 0.78,
    daysLeft: '3 Days',
  ),
];
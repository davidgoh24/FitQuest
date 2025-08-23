// leaderboard_content.dart
import 'package:flutter/material.dart';
import 'challenge_leaderboard.dart';
import 'tournament_leaderboard.dart';
import 'levels_leaderboard.dart';

class LeaderboardContent extends StatelessWidget {
  final bool isChallengeSelected;
  final bool isTournamentSelected;

  const LeaderboardContent({
    super.key,
    required this.isChallengeSelected,
    required this.isTournamentSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isChallengeSelected) {
      return const ChallengeLeaderboardWidget();
    } else if (isTournamentSelected) {
      return const TournamentLeaderboardWidget();
    } else {
      return const LevelsLeaderboardWidget();
    }
  }
}
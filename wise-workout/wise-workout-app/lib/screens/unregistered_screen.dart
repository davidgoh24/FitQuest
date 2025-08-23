import 'package:flutter/material.dart';
import '../widgets/exercise_stats_card.dart';
import '../widgets/tournament_widget.dart';
import '../widgets/workout_card_home_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/workout_category_service.dart';
import '../services/tournament_service.dart';

class UnregisteredUserPage extends StatelessWidget {
  final int currentSteps = 0;
  final int maxSteps = 0;
  final double caloriesBurned = 0.0;
  final int xpEarned = 0;

  const UnregisteredUserPage({super.key});

  void _showRegistrationPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('unreg_dialog_title'.tr()),
        content: Text('unreg_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('unreg_dialog_later'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
            child: Text('unreg_dialog_register'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _wrapWithPrompt(BuildContext context, Widget child) {
    return GestureDetector(
      onTap: () => _showRegistrationPrompt(context),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final surfaceColor =
        brightness == Brightness.dark ? Colors.grey[800] : colorScheme.surface;
    final hintTextColor =
        brightness == Brightness.dark ? Colors.grey[400] : theme.hintColor;
    final bannerColor =
        brightness == Brightness.dark ? const Color(0xFF1E1E2C) : colorScheme.primary;
    final bannerContrast = colorScheme.onPrimary;
    final bannerAccent = colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'unreg_welcome_title'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: Text(
                        'unreg_button_login'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _wrapWithPrompt(
                  context,
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            'unreg_search_placeholder'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: hintTextColor,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(Icons.search, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Exercise Stats
              _wrapWithPrompt(
                context,
                ExerciseStatsCard(
                  currentSteps: currentSteps,
                  maxSteps: maxSteps,
                  caloriesBurned: double.parse(caloriesBurned.toStringAsFixed(1)),
                  xpEarned: xpEarned,
                  exerciseGaugeColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Workout Title
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'unreg_workout_title'.tr(),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 10),

              // Workout Cards
              SizedBox(
                height: 120,
                child: FutureBuilder<List<WorkoutCategory>>(
                  future: WorkoutCategoryService().fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load categories'));
                    }
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) {
                      return const Center(child: Text('No workout categories available'));
                    }
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: categories.map((cat) {
                        return WorkoutCardHomeScreen(
                          imagePath: cat.imageUrl,
                          workoutName: cat.categoryName,
                          workoutLevel: '',
                          onTap: () => _showRegistrationPrompt(context), // only prompt
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Challenge Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _wrapWithPrompt(
                  context,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: bannerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'unreg_challenge_title'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: bannerContrast,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'unreg_challenge_desc'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: bannerContrast.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: bannerAccent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text(
                            'unreg_challenge_button'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tournament Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'unreg_tournaments_title'.tr(),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 10),

              // Tournaments
              SizedBox(
                height: 220,
                child: FutureBuilder<List<dynamic>>(
                  future: TournamentService().getTournamentsWithParticipants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading tournaments'));
                    }
                    final tournaments = snapshot.data ?? [];
                    if (tournaments.isEmpty) {
                      return const Center(child: Text('No tournaments available'));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: tournaments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, index) {
                        final t = tournaments[index];
                        return _wrapWithPrompt(
                          context,
                          TournamentWidget(
                            tournamentName: t['title'] ?? '',
                            daysLeft: t['endDate'] ?? '',
                            participants: t['participants']?.toString() ?? '0',
                            cardWidth: 280,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _showRegistrationPrompt(context),
        isRegistered: false,
      ),
    );
  }
}

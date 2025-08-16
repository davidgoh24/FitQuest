import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../model/exercise_model.dart';
import 'exercise_video_tutorial.dart';
import '../buypremium_screen.dart';
import '../../services/api_service.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});
  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isPremiumUser = false;
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await ApiService().getCurrentProfile();
    if (profile != null) {
      setState(() {
        _isPremiumUser = profile['role'] == 'premium';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: colorScheme.surfaceVariant ?? colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _getExerciseImagePath(widget.exercise.exerciseName),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surface,
                      child: Icon(Icons.fitness_center, size: 100, color: colorScheme.outline),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_isPremiumUser) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseVideoTutorial(exercise: widget.exercise),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BuyPremiumScreen()),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text('exercise_play_tutorial').tr(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPremiumUser
                                ? colorScheme.secondary
                                : colorScheme.surfaceVariant ?? colorScheme.surface,
                            foregroundColor: colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        if (!_isPremiumUser)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Unlock tutorial with Premium",
                              style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDetailContent(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/exercise-log',
              arguments: widget.exercise,
            );
          },
          icon: const Icon(Icons.photo_camera),
          label: Text("exercise_start_button").tr(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final exercise = widget.exercise;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.exerciseName,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildSectionTitle('exercise_overview'.tr(), context),
        Text(
          exercise.exerciseDescription,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('exercise_expect'.tr(), context),
        Text(
          '- Full-body warm-up\n'
              '- Strength moves (e.g., push-ups, squats, planks)\n'
              '- Balance, endurance & posture\n'
              '- Cooldown with mobility work',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        if (exercise.exerciseLevel != null && exercise.exerciseLevel!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('exercise_level'.tr(), context),
              Text(exercise.exerciseLevel!, style: textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
          ),

        if (exercise.exerciseEquipment != null && exercise.exerciseEquipment!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('exercise_equipment'.tr(), context),
              Text(exercise.exerciseEquipment!, style: textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
          ),

        _buildSectionTitle('exercise_instructions'.tr(), context),
        ..._buildInstructionList(exercise.exerciseInstructions, context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        fontSize: 16,
      ),
    );
  }

  List<Widget> _buildInstructionList(String instructions, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parts = instructions.split(RegExp(r'\n|\r'));
    return List.generate(parts.length, (i) {
      return Text(
        '${i + 1}. ${parts[i]}',
        style: textTheme.bodyMedium,
      );
    });
  }

  String _getExerciseImagePath(String exerciseTitle) {
    final formatted = exerciseTitle.toLowerCase().replaceAll(' ', '_');
    return 'assets/exerciseGif/$formatted.gif';
  }
}
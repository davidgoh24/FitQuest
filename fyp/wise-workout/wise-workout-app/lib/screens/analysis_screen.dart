import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AnalysisScreen extends StatelessWidget {
  final String date;
  final String workout;
  final IconData icon;
  final String duration;
  final double calories;
  final String intensity;
  final String? notes;
  final Map<String, dynamic>? extraStats;

  const AnalysisScreen({
    Key? key,
    required this.date,
    required this.workout,
    required this.icon,
    required this.duration,
    required this.calories,
    required this.intensity,
    this.notes,
    this.extraStats,
  }) : super(key: key);

  String buildShareContent() {
    final stats = extraStats ?? {
      "Steps": "0",
      "Sets": workout == "Strength Training" ? "4" : null,
      "Reps": workout == "Strength Training" ? "12, 10, 8, 8" : null,
      "Max Weight": workout == "Strength Training" ? "30 kg" : null,
      "Pace": workout.contains("HIIT") ? "Very Fast" : null,
      "Calories per min": (calories / (int.tryParse(duration.split(" ").first) ?? 1)).toStringAsFixed(1),
    };
    String statString = stats.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => "${e.key}: ${e.value}")
        .join("\n");
    String text =
        "🏋️ Workout: $workout\n📅 Date: $date\n⏱ Duration: $duration\n🔥 Calories: $calories kcal\n"
        "⬆️ Intensity: $intensity\n$statString";
    if (notes != null && notes!.trim().isNotEmpty) {
      text += "\n📝 Notes: ${notes!}";
    }
    text += "\n\nShared via FitQuest 💪";
    return text;
  }

  void _showShareEditDialog(BuildContext context, String initialText) {
    final controller = TextEditingController(text: initialText);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final padding = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit your share message',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  minLines: 4,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: Icon(Icons.share, color: colorScheme.onPrimary),
                    label: Text("Share", style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
                    onPressed: () {
                      final msg = controller.text.trim();
                      if (msg.isNotEmpty) {
                        Share.share(msg, subject: "My Workout Accomplishment!");
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = extraStats ?? {
      "Steps": "0",
      "Sets": workout == "Strength Training" ? "4" : null,
      "Reps": workout == "Strength Training" ? "12, 10, 8, 8" : null,
      "Max Weight": workout == "Strength Training" ? "30 kg" : null,
      "Pace": workout.contains("HIIT") ? "Very Fast" : null,
      "Calories per min": (calories / (int.tryParse(duration.split(" ").first) ?? 1)).toStringAsFixed(1),
    };

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        title: Text(
          "Workout Analysis",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 32),
                  radius: 32,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout,
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 5),
                          Text(
                            date,
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _statCard(context, Icons.timer, "Duration", duration)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(context, Icons.local_fire_department, "Calories", "$calories kcal")),
                const SizedBox(width: 8),
                Expanded(child: _statCard(context, Icons.trending_up, "Intensity", intensity)),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              "Detailed Stats",
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...stats.entries
                .where((e) => e.value != null && e.value.toString().isNotEmpty)
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            e.key,
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          )),
                          Text(
                            e.value.toString(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
            if (notes != null && notes!.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                "Session Notes",
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                notes!,
                style: textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showShareEditDialog(context, buildShareContent());
        },
        icon: Icon(Icons.share, color: colorScheme.onPrimary),
        label: Text("Share", style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(1, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.onSurface, size: 28),
          const SizedBox(height: 5),
          FittedBox( // Prevents wrapping and keeps it looking good
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

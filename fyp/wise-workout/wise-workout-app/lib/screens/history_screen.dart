import 'package:flutter/material.dart';
import 'analysis_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/workout_service.dart';
import '../services/health_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> workoutHistory = [];
  bool isLoading = true;
  String errorMessage = '';
  final healthService = HealthService();
  final workoutService = WorkoutService();

  @override
  void initState() {
    super.initState();
    _fetchWorkoutHistory();
  }

  Future<void> _fetchWorkoutHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final history = await workoutService.fetchUserWorkoutSessions();

      final enrichedHistory = await Future.wait(history.map((entry) async {
        try {
          final intensity = await workoutService.fetchSessionIntensity(entry['session_id']);
          entry['intensity'] = intensity;
        } catch (_) {
          entry['intensity'] = 'Unknown';
        }
        return entry;
      }));

      setState(() {
        workoutHistory = enrichedHistory;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error fetching workout history: $e');
    }
  }

  IconData _getIconForWorkout(String? workoutName) {
    if (workoutName == null) return Icons.fitness_center;
    final name = workoutName.toLowerCase();
    if (name.contains('yoga') || name.contains('relax')) {
      return Icons.self_improvement;
    } else if (name.contains('cardio') || name.contains('hiit')) {
      return Icons.flash_on;
    } else if (name.contains('core')) {
      return Icons.accessibility_new;
    } else {
      return Icons.fitness_center;
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '0 min';
    final minutes = (seconds / 60).round();
    return '$minutes min';
  }

  double _parseCalories(dynamic rawCalories) {
    if (rawCalories == null) return 0.0;
    if (rawCalories is double) return rawCalories;
    if (rawCalories is int) return rawCalories.toDouble();
    if (rawCalories is String) return double.tryParse(rawCalories) ?? 0.0;
    return 0.0;
  }

  Future<void> _openAnalysisScreen(Map<String, dynamic> entry) async {
    final dateString = entry['start_time']?.substring(0, 10) ?? 'Unknown Date';
    final steps = await healthService.getStepsForDate(DateTime.parse(dateString));

    final intensity = entry['intensity'] ??
        await workoutService.fetchSessionIntensity(entry['session_id']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          date: dateString,
          workout: entry['workout_name'] ?? 'Workout Session',
          icon: _getIconForWorkout(entry['workout_name']),
          duration: _formatDuration(entry['duration']),
          calories: _parseCalories(entry['calories_burned']),
          intensity: intensity,
          notes: entry['notes'] ?? '',
          extraStats: {
            "Steps": steps.toString(),
            "Calories per min": (() {
              final minutes = int.tryParse(_formatDuration(entry['duration']).split(" ").first) ?? 0;
              final cals = _parseCalories(entry['calories_burned']);
              if (minutes <= 0 || cals <= 0) return "0.0";
              return (cals / minutes).toStringAsFixed(1);
            })(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'history_title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading history: $errorMessage',
                              style: const TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchWorkoutHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : workoutHistory.isEmpty
                        ? Center(
                            child: Text(
                              'history_empty_message'.tr(),
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchWorkoutHistory,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: workoutHistory.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final entry = workoutHistory[i];
                                final calories = _parseCalories(entry['calories_burned']);

                                return GestureDetector(
                                  onTap: () => _openAnalysisScreen(entry),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          _getIconForWorkout(entry['workout_name']),
                                          color: const Color(0xFF071655),
                                          size: 40,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry['start_time']?.substring(0, 10) ?? 'Unknown Date',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF071655),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                entry['workout_name'] ?? 'Workout Session',
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDuration(entry['duration']),
                                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  const Icon(Icons.local_fire_department, size: 16, color: Colors.amber),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${calories.toStringAsFixed(1)} kcal",
                                                    style: const TextStyle(color: Colors.amber, fontSize: 13),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  const Icon(Icons.trending_up, size: 16, color: Colors.deepPurple),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    entry['intensity'] ?? 'Unknown',
                                                    style: const TextStyle(fontSize: 13, color: Colors.deepPurple),
                                                  ),
                                                ],
                                              ),
                                              if (entry['notes'] != null &&
                                                  entry['notes'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    entry['notes'].toString(),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

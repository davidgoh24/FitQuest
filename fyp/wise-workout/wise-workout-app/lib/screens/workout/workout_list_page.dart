import 'package:flutter/material.dart';
import '../model/workout_model.dart';
import '../../services/workout_service.dart';
import '../../widgets/workout_tile.dart';
import 'package:easy_localization/easy_localization.dart';

class WorkoutListPage extends StatefulWidget {
  final String categoryKey;
  const WorkoutListPage({super.key, required this.categoryKey});
  @override
  State<WorkoutListPage> createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  late Future<List<Workout>> workoutList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    workoutList = WorkoutService().fetchWorkoutsByCategory(widget.categoryKey);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: FutureBuilder<List<Workout>>(
        future: workoutList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary)
            );
          }
          if (snapshot.hasError) {
            final errorMessage = snapshot.error?.toString() ?? 'Unknown error';
            return Center(
                child: Text(
                  '${tr('workout_list_error')}: $errorMessage',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                  tr('workout_list_empty'),
                  style: textTheme.bodyLarge,
                ));
          }
          final workouts = snapshot.data!
              .where((workout) => workout.workoutName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
              .toList();
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 250,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/workoutCategory/${widget.categoryKey}.jpg',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.surface.withOpacity(0.8),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            widget.categoryKey.toUpperCase(),
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 50,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: Stack(
              children: [
                Container(color: colorScheme.background),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: tr('workout_list_search_hint'),
                          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${workouts.length} ${tr('workout_list_found')}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: WorkoutTile(
                              workout: workout,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/exercise-list-page',
                                  arguments: {
                                    'workoutId': workout.workoutId,
                                    'workoutName': workout.workoutName,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/workout_category_service.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/workout_card_dashboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'fitness_plan_screen.dart';
import '../buypremium_screen.dart';
import '../../services/api_service.dart';

class WorkoutCategoryDashboard extends StatefulWidget {
  @override
  _WorkoutCategoryDashboardState createState() => _WorkoutCategoryDashboardState();
}

class _WorkoutCategoryDashboardState extends State<WorkoutCategoryDashboard> {
  int _currentIndex = 2;
  String? _selectedCategory;
  late Future<List<WorkoutCategory>> _categoryFuture;
  List<WorkoutCategory> _allCategories = [];
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _categoryFuture = WorkoutCategoryService().fetchCategories();
    _fetchProfile();
  }

  void _filterByCategory(String? categoryKey) {
    setState(() {
      _selectedCategory = categoryKey;
    });
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 32,
              left: 8,
              right: 8,
              bottom: 10,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      tr('workout_categories_title'),
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.list_alt_rounded,
                    color: _isPremiumUser
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.45),
                    size: 28,
                  ),
                  tooltip: tr('my_workout_plans_tooltip'),
                  onPressed: () {
                    if (_isPremiumUser) {
                      Navigator.pushNamed(
                        context,
                        '/workout-plans-screen',
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyPremiumScreen()),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.auto_awesome,
                    color: _isPremiumUser
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.45),
                    size: 28,
                  ),
                  tooltip: tr('ai_fitness_plan_tooltip'),
                  onPressed: () {
                    if (_isPremiumUser) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FitnessPlanScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyPremiumScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FutureBuilder<List<WorkoutCategory>>(
              future: _categoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                } else if (snapshot.hasError) {
                  return Center(child: Text(tr('workout_categories_error'), style: textTheme.bodyLarge));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(tr('workout_categories_empty'), style: textTheme.bodyLarge));
                }
                _allCategories = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _filterByCategory(null);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: _selectedCategory == null
                                ? colorScheme.primary
                                : colorScheme.surfaceVariant,
                            foregroundColor: _selectedCategory == null
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            elevation: 0,
                          ),
                          child: Text(
                            tr('workout_categories_all'),
                            style: textTheme.labelLarge,
                          ),
                        ),
                      ),
                      ..._allCategories.map((category) {
                        final isSelected = _selectedCategory == category.categoryKey;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _filterByCategory(category.categoryKey);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceVariant,
                              foregroundColor: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              elevation: 0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  category.categoryName,
                                  style: textTheme.labelLarge,
                                ),
                                if (isSelected)
                                  Icon(Icons.check, color: colorScheme.onPrimary, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<WorkoutCategory>>(
              future: _categoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: textTheme.bodyLarge));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(tr('workout_categories_not_found'), style: textTheme.bodyLarge));
                }
                final filteredCategories = _selectedCategory == null
                    ? snapshot.data!
                    : snapshot.data!.where((c) => c.categoryKey == _selectedCategory).toList();
                return ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return WorkoutCardDashboard(
                      title: category.categoryName,
                      subtitle: category.categoryDescription,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/workout-list-page',
                          arguments: {
                            'categoryKey': category.categoryKey,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/leaderboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/workout-category-dashboard');
              break;
            case 3:
              Navigator.pushNamed(context, '/messages');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}
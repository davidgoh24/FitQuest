import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';

import 'themes/app_theme.dart';
import 'themes/christmas_theme.dart';
import 'themes/theme_notifier.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/workout_tracker.dart';
import 'screens/challenge_screen(removed).dart';
import 'screens/questionnaires/questionnaire_screen.dart';
import 'screens/questionnaires/questionnaire_screen_2.dart';
import 'screens/questionnaires/questionnaire_screen_3.dart';
import 'screens/questionnaires/questionnaire_screen_4.dart';
import 'screens/questionnaires/questionnaire_screen_5.dart';
import 'screens/questionnaires/questionnaire_screen_6.dart';
import 'screens/questionnaires/questionnaire_screen_7.dart';
import 'screens/questionnaires/questionnaire_screen_8.dart';
import 'screens/questionnaires/questionnaire_screen_9.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_reset_screen.dart';
import 'screens/unregistered_screen.dart';
import 'screens/badge_collection.dart';
import 'screens/wearable_screen.dart';
import 'screens/history_screen.dart';
import 'screens/buypremium_screen.dart';
import 'screens/message_screen.dart';
import 'screens/change_password.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/workout/exercise_detail_screen.dart';
import 'screens/workout/workout_analysis_page.dart';
import 'screens/workout/workout_category_dashboard.dart';
import 'screens/workout/workout_list_page.dart';
import 'screens/appearance_screen.dart';
import 'screens/language_settings_screen.dart';
import 'services/exercise_service.dart';
import 'screens/model/exercise_model.dart';
import 'screens/workout/exercise_list_page.dart';
import 'screens/view_challenge_tournament_screen.dart';
import 'screens/workout/exercise_log_page.dart';
import 'screens/workout/daily_summary_page.dart';
import 'screens/workout/weekly_monthly_summary.dart';
import 'screens/workout/fitness_plan_calendar.dart';
import 'screens/workout/workout_plans_screen.dart';
import 'screens/workout/workout_plan_exercise_list.dart';
import 'widgets/persistent_workout_timer_overlay.dart';
import 'screens/workout/exercise_list_from_ai_page.dart';
import 'screens/calendar_sync_screen.dart';
import 'services/reminder_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService.init();

  // Default to English if not set
  Locale initialLocale = const Locale('en');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
        Locale('zh'),
        Locale('ms'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: initialLocale,
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const WiseWorkoutApp(),
      ),
    ),
  );
}

class WiseWorkoutApp extends StatefulWidget {
  const WiseWorkoutApp({super.key});

  @override
  State<WiseWorkoutApp> createState() => _WiseWorkoutAppState();
}

class _WiseWorkoutAppState extends State<WiseWorkoutApp> {
  final ApiService _apiService = ApiService();
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _determineStartRoute();
  }
 
  Future<void> _determineStartRoute() async {
    final isAuthenticated = await _apiService.checkAuthStatus();

    if (isAuthenticated) {
      try {
        final lang = await _apiService.getLanguage();
        if (lang.isNotEmpty && mounted) {
          context.setLocale(Locale(lang));
        }
        final reminderService = ReminderService();
        await reminderService.syncAndSchedule();

      } catch (e) {
        print('Error loading user preferences: $e');
      }
    }

    setState(() {
      _initialRoute = isAuthenticated ? '/home' : '/unregistered';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final themeNotifier = Provider.of<ThemeNotifier>(context);

    ThemeData usedTheme;
    if (themeNotifier.appThemeMode == AppThemeMode.christmas) {
      usedTheme = christmasTheme;
    } else if (themeNotifier.appThemeMode == AppThemeMode.normal) {
      usedTheme = AppTheme.lightTheme;
    } else {
      usedTheme = AppTheme.lightTheme;
    }

    return MaterialApp(
      title: 'Wise Workout',
      debugShowCheckedModeBanner: false,
      theme: usedTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: rootNavigatorKey,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => child),
            OverlayEntry(builder: (_) => const PersistentWorkoutTimerOverlay()),
          ],
        );
      },
      initialRoute: _initialRoute!,
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(userName: ''),
        '/profile': (context) => ProfileScreen(userName: ''),
        '/register': (context) => const RegisterScreen(),
        '/workout': (context) => WorkoutTracker(),
        '/competition': (context) => ChallengeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-reset': (context) => const VerifyResetScreen(),
        '/unregistered': (context) => const UnregisteredUserPage(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/badge-collections': (context) => const BadgeCollectionScreen(),
        '/wearable-screen': (context) => const WearableScreen(),
        '/workout-history': (context) => const HistoryScreen(),
        '/premium-plan': (context) => BuyPremiumScreen(),
        '/messages': (context) => const MessageScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/workout-category-dashboard': (context) => WorkoutCategoryDashboard(),
        '/appearance-settings': (context) => AppearanceScreen(),
        '/exercise-detail': (context) => ExerciseDetailScreen(
          exercise: ModalRoute.of(context)!.settings.arguments as Exercise,
        ),
        '/workout-analysis': (context) => const WorkoutAnalysisPage(),
        '/language-settings': (context) => const LanguageSettingsScreen(),
        '/dailySummary': (context) => const DailySummaryPage(),
        '/weekly-monthly-summary': (context) => const WeeklyMonthlySummaryPage(),
        '/calendar': (context) => const CalendarPlanScreen(),
        '/workout-plans-screen': (context) => const WorkoutPlansScreen(),
        '/calendar-sync': (context) => const CalendarSyncScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/workout-list-page') {
          final args = settings.arguments as Map<String, dynamic>;
          final categoryKey = args['categoryKey'];
          return MaterialPageRoute(
            builder: (_) => WorkoutListPage(categoryKey: categoryKey),
          );
        }
        if (settings.name == '/workout-plan-exercise-list') {
          final args = settings.arguments as Map<String, dynamic>;
          final title = args['planTitle'] as String;
          final names = (args['exerciseNames'] as List).cast<String>();
          return MaterialPageRoute(
            builder: (_) => WorkoutPlanExerciseList(
              planTitle: title,
              exerciseNames: names,
            ),
          );
        }
        if (settings.name == '/exercise-list-page') {
          final args = settings.arguments as Map<String, dynamic>;
          final workoutId = args['workoutId'];
          final workoutName = args['workoutName'];
          return MaterialPageRoute(
            builder: (_) => ExerciseListPage(
              workoutId: workoutId,
              workoutName: workoutName,
            ),
          );
        }
        if (settings.name == '/exercise-log') {
          final Exercise exercise = settings.arguments as Exercise;
          return MaterialPageRoute(
            builder: (context) => ExerciseLogPage(exercise: exercise),
          );
        }
        if (settings.name == '/challenge-list') {
          final args = settings.arguments as Map<String, dynamic>;
          final bool isPremium = args['isPremium'] ?? false;
          return MaterialPageRoute(
            builder: (_) => ViewChallengeTournamentScreen(isPremium: isPremium),
          );
        }
        if (settings.name == '/exercise-list-from-ai') {
          final args = settings.arguments as Map<String, dynamic>;
          final List<String> names = (args['exerciseNames'] as List).cast<String>();
          final String dayLabel = args['dayLabel'] as String;
          return MaterialPageRoute(
            builder: (_) => ExerciseListFromAIPage(
              exerciseNames: names,
              dayLabel: dayLabel,
            ),
          );
        }
        return null;
      },
    );
  }
}

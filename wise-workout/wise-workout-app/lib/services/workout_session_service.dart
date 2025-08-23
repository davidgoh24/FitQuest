import 'dart:async';

class WorkoutSessionService {
  static final WorkoutSessionService _instance = WorkoutSessionService._internal();
  factory WorkoutSessionService() => _instance;
  WorkoutSessionService._internal();

  String? _workoutName;
  bool _isActive = false;

  Duration _elapsed = Duration.zero;
  Timer? _timer;

  final List<Map<String, dynamic>> _loggedExercises = [];
  final StreamController<Duration> _elapsedController = StreamController.broadcast();

  String? _startRouteName;
  Map<String, dynamic>? _startRouteArgs;

  Stream<Duration> get elapsedStream => _elapsedController.stream;
  bool get isActive => _isActive;
  Duration get elapsed => _elapsed;
  String? get workoutName => _workoutName;
  List<Map<String, dynamic>> get loggedExercises => _loggedExercises;

  String? get startRouteName => _startRouteName;
  Map<String, dynamic>? get startRouteArgs => _startRouteArgs;

  void setWorkoutName(String name) {
    _workoutName = name;
  }

  void setStartContext(String routeName, {Map<String, dynamic>? args}) {
    _startRouteName = routeName;
    _startRouteArgs = args;
  }

  void start([void Function(Duration)? onElapsed]) {
    if (_isActive) return;
    _isActive = true;
    _elapsed = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      _elapsedController.add(_elapsed);
      if (onElapsed != null) onElapsed(_elapsed);
    });
  }

  void addExerciseLog(Map<String, dynamic> log) {
    print('DEBUG: Adding exercise log to session: $log');
    print('DEBUG: Current session exercises before adding: $_loggedExercises');
    _loggedExercises.add(log);
    print('DEBUG: Current session exercises after adding: $_loggedExercises');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _elapsedController.add(_elapsed);
  }

  void clearSession() {
    stop();
    _elapsed = Duration.zero;
    _workoutName = null;
    _loggedExercises.clear();
    _elapsedController.add(_elapsed);

    _startRouteName = null;
    _startRouteArgs = null;
  }

  void dispose() {
    _timer?.cancel();
    _elapsedController.close();
  }
}

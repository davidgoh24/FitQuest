import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<bool> connect() async {
    try {
      await _health.configure();

      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ];
      final permissions = types.map((e) => HealthDataAccess.READ).toList();

      bool granted = await _health.requestAuthorization(types, permissions: permissions);

      if (granted) {
        try {
          final historyGranted = await _health.isHealthDataHistoryAuthorized();
          if (!historyGranted) {
            final historyRequestResult =
                await _health.requestHealthDataHistoryAuthorization();
            granted = granted && historyRequestResult;
          }
        } catch (e) {
          print('Error requesting history permission: $e');
        }
      }

      return granted;
    } on UnsupportedError {
      await _health.installHealthConnect();
      return false;
    } catch (e) {
      print('Error connecting to Health Connect: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      await _health.revokePermissions(); 
      return true; 
    } catch (e) {
      print('Error revoking permissions: $e');
      return false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<int> getStepsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final isToday = _isSameDay(date, DateTime.now());
    final endOfDay =
        isToday ? DateTime.now() : startOfDay.add(const Duration(days: 1));
    try {
      final totalSteps =
          await _health.getTotalStepsInInterval(startOfDay, endOfDay);
      return totalSteps ?? 0;
    } catch (e) {
      print('Error fetching steps for $date: $e');
      return 0;
    }
  }

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final totalSteps =
          await _health.getTotalStepsInInterval(startOfDay, now);
      return totalSteps ?? 0;
    } catch (e) {
      print('Error fetching today\'s steps: $e');
      return 0;
    }
  }

  Future<List<HealthDataPoint>> getHeartRateDataInRange(
      DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );
      return data;
    } catch (e) {
      print('Error fetching heart rate data: $e');
      return [];
    }
  }

  Future<List<HealthDataPoint>> getTodayHeartRateData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: now,
      );
      return data;
    } catch (e) {
      print('Error fetching today\'s heart rate data: $e');
      return [];
    }
  }

  Future<List<int>> getHourlyStepsForDate(DateTime date) async {
    final hourlySteps = List<int>.filled(24, 0);
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final maxHour = isToday ? now.hour : 23;

    for (int hour = 0; hour <= maxHour; hour++) {
      final hourStart = DateTime(date.year, date.month, date.day, hour);
      final hourEnd =
          (isToday && hour == now.hour) ? now : hourStart.add(const Duration(hours: 1));
      if (!hourEnd.isAfter(hourStart)) {
        hourlySteps[hour] = 0;
        continue;
      }
      try {
        final steps =
            await _health.getTotalStepsInInterval(hourStart, hourEnd);
        hourlySteps[hour] = steps ?? 0;
      } catch (e) {
        print('Error fetching hourly steps for $hour: $e');
        hourlySteps[hour] = 0;
      }
    }
    return hourlySteps;
  }

  Future<int> getStepsInRange(DateTime start, DateTime end) async {
    try {
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      print('Error getting steps in range: $e');
      return 0;
    }
  }

  Future<List<int>> getDailyStepsInRange(DateTime start, DateTime end) async {
    final days = end.difference(start).inDays + 1;
    final stepsPerDay = <int>[];
    for (int i = 0; i < days; i++) {
      final dayStart = DateTime(start.year, start.month, start.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1));
      try {
        final steps =
            await _health.getTotalStepsInInterval(dayStart, dayEnd);
        stepsPerDay.add(steps ?? 0);
      } catch (e) {
        print('Error fetching daily steps for $dayStart: $e');
        stepsPerDay.add(0);
      }
    }
    return stepsPerDay;
  }
}

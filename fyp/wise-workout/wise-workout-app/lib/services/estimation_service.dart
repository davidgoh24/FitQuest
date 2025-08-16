// lib/services/estimation_service.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'health_service.dart';

enum FitnessGoal { trend, weightLoss, muscleGain }

@immutable
class EstimationResult {
  final List<DateTime> datesActual;
  final List<int> caloriesActual;
  final List<DateTime> datesForecast;
  final List<int> caloriesForecast;
  final double last7Avg;
  final double prev7Avg;
  final double trendPct;
  final int last7Total;
  final int next7TotalForecast;
  final FitnessGoal goal; // NEW

  const EstimationResult({
    required this.datesActual,
    required this.caloriesActual,
    required this.datesForecast,
    required this.caloriesForecast,
    required this.last7Avg,
    required this.prev7Avg,
    required this.trendPct,
    required this.last7Total,
    required this.next7TotalForecast,
    required this.goal,
  });
}

class EstimationService {
  final HealthService healthService;
  EstimationService(this.healthService);

  Future<EstimationResult> buildCaloriesWeeklyEstimate({
    DateTime? endDate,
    int historyDays = 28,
    int actualDaysToPlot = 7,
    int forecastDays = 7,
    FitnessGoal goal = FitnessGoal.trend,
    double? weightKg,
    int? heightCm,
    String? gender,
  }) async {
    final now = endDate ?? DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(Duration(days: historyDays - 1));

    // Pull STEPS only; convert to kcal
    final stepsDaily = await healthService.getDailyStepsInRange(
      DateTime(start.year, start.month, start.day),
      DateTime(end.year, end.month, end.day),
    );

    final daily = _stepsToCalories(
      stepsDaily,
      weightKg: weightKg ?? 70.0,
      heightCm: heightCm ?? 170,
    );

    // Build date axis for all history
    final allDates = List<DateTime>.generate(
      daily.length,
          (i) => DateTime(start.year, start.month, start.day).add(Duration(days: i)),
    );

    // If zero data, synthesize a tiny history so the chart isn't flat
    final List<int> dailyNonEmpty;
    final List<DateTime> datesNonEmpty;
    if (daily.isEmpty || daily.every((e) => e == 0)) {
      final synthLen = math.min(7, historyDays);
      final fallback = _syntheticDailyFromWeight(
        length: synthLen,
        weightKg: weightKg ?? 70,
        heightCm: heightCm ?? 170,
      );
      dailyNonEmpty = fallback;
      datesNonEmpty = List<DateTime>.generate(synthLen, (i) => end.subtract(Duration(days: synthLen - 1 - i)));
    } else {
      dailyNonEmpty = daily;
      datesNonEmpty = allDates;
    }

    // Trend stats from last 14 days of non-empty data
    final last7 = _tail(dailyNonEmpty, 7);
    final prev7 = _slice(dailyNonEmpty, dailyNonEmpty.length - 14, dailyNonEmpty.length - 7);
    final last7Avg = last7.isNotEmpty ? last7.reduce((a, b) => a + b) / last7.length : 0.0;
    final prev7Avg = prev7.isNotEmpty ? prev7.reduce((a, b) => a + b) / prev7.length : 0.0;
    final trendPct = ((prev7Avg <= 0) ? 0.0 : (last7Avg - prev7Avg) / prev7Avg).clamp(-0.30, 0.30);

    // Weekday seasonality excluding most recent 7 days (if available)
    final cutoff = math.max(0, dailyNonEmpty.length - 7);
    final seasonality = _weekdaySeasonality(
      dates: datesNonEmpty.sublist(0, cutoff),
      values: dailyNonEmpty.sublist(0, cutoff),
    );

    // Forecast next 7 days
    final baseline = (last7Avg > 0 ? last7Avg : dailyNonEmpty.isNotEmpty ? dailyNonEmpty.last.toDouble() : 250.0);

    final datesForecast = List<DateTime>.generate(forecastDays, (i) => end.add(Duration(days: i + 1)));
    final List<int> caloriesForecast;

    if (goal == FitnessGoal.trend) {
      // ORIGINAL behavior
      caloriesForecast = datesForecast.map((d) {
        final f = seasonality[_weekdayIdx(d)] ?? 1.0;
        final v = baseline * f * (1.0 + trendPct);
        return math.max(0, v.round());
      }).toList();
    } else if (goal == FitnessGoal.weightLoss) {
      // Push toward higher daily burn target (baseline + ~300 kcal), softly shaped by seasonality
      final target = (baseline + 300).clamp(250, 1500); // guardrails
      caloriesForecast = datesForecast.map((d) {
        final f = seasonality[_weekdayIdx(d)] ?? 1.0;
        final v = target * f * 0.98; // slight moderation
        return math.max(0, v.round());
      }).toList();
    } else {
      // FitnessGoal.muscleGain
      // Keep cardio near baseline, add strength days spikes (Mon/Wed/Fri +200kcal)
      caloriesForecast = datesForecast.map((d) {
        final f = seasonality[_weekdayIdx(d)] ?? 1.0;
        double v = baseline * f * 0.95;
        if (d.weekday == DateTime.monday || d.weekday == DateTime.wednesday || d.weekday == DateTime.friday) {
          v += 200; // strength session burn
        }
        return math.max(0, v.round());
      }).toList();
    }

    // Plot last 14 actual days from (possibly) non-empty series
    final plotCount = math.min(actualDaysToPlot, dailyNonEmpty.length);
    final datesActual = datesNonEmpty.sublist(dailyNonEmpty.length - plotCount);
    final caloriesActual = dailyNonEmpty.sublist(dailyNonEmpty.length - plotCount);

    final last7Total = last7.fold<int>(0, (s, v) => s + v);
    final next7TotalForecast = caloriesForecast.fold<int>(0, (s, v) => s + v);

    return EstimationResult(
      datesActual: datesActual,
      caloriesActual: caloriesActual,
      datesForecast: datesForecast,
      caloriesForecast: caloriesForecast,
      last7Avg: last7Avg,
      prev7Avg: prev7Avg,
      trendPct: trendPct,
      last7Total: last7Total,
      next7TotalForecast: next7TotalForecast,
      goal: goal, // NEW
    );
  }

  // ----- helpers -----
  List<int> _stepsToCalories(List<int> stepsDaily, {required double weightKg, required int heightCm}) {
    const stepLenFactor = 0.415;
    final strideM = (heightCm * stepLenFactor) / 100.0;
    const kcalPerKgKm = 0.53;
    return List<int>.generate(stepsDaily.length, (i) {
      final km = (stepsDaily[i] * strideM) / 1000.0;
      final kcal = km * weightKg * kcalPerKgKm;
      return kcal.round();
    });
  }

  // If no data, synthesize ~6k steps/day into kcal for a reasonable baseline
  List<int> _syntheticDailyFromWeight({required int length, required double weightKg, required int heightCm}) {
    const defaultSteps = 6000;
    const stepLenFactor = 0.415;
    final strideM = (heightCm * stepLenFactor) / 100.0;
    const kcalPerKgKm = 0.53;
    final kcal = ((defaultSteps * strideM) / 1000.0) * weightKg * kcalPerKgKm;
    return List<int>.filled(length, kcal.round());
  }

  int _weekdayIdx(DateTime d) => (d.weekday - 1).clamp(0, 6);
  List<int> _tail(List<int> src, int n) => n >= src.length ? List<int>.from(src) : src.sublist(src.length - n);
  List<int> _slice(List<int> src, int start, int end) {
    final s = math.max(0, start);
    final e = math.min(src.length, end);
    return s >= e ? const [] : src.sublist(s, e);
  }

  Map<int, double> _weekdaySeasonality({required List<DateTime> dates, required List<int> values}) {
    if (dates.isEmpty || values.isEmpty) return {for (var i = 0; i < 7; i++) i: 1.0};
    final sums = List<double>.filled(7, 0.0);
    final cnts = List<int>.filled(7, 0);
    double total = 0; int n = 0;
    for (int i = 0; i < dates.length; i++) {
      final idx = _weekdayIdx(dates[i]);
      final v = values[i].toDouble();
      sums[idx] += v; cnts[idx] += 1; total += v; n += 1;
    }
    final overall = n == 0 ? 1.0 : (total / n);
    return {
      for (int i = 0; i < 7; i++)
        i: overall == 0 ? 1.0 : ((cnts[i] == 0 ? overall : (sums[i] / cnts[i])) / overall)
    };
  }
}

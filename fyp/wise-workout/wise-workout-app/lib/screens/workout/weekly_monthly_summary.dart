import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/health_service.dart';
import '../../widgets/time_based_chart.dart';
import '../../widgets/week_picker_dialog.dart';
import '../../services/workout_service.dart';
import '../../services/api_service.dart';
import '../../services/estimation_service.dart';
import 'dart:math' as math;
import '../../widgets/calorie_forecast_card.dart';

class WeeklyMonthlySummaryPage extends StatefulWidget {
  const WeeklyMonthlySummaryPage({super.key});
  @override
  State<WeeklyMonthlySummaryPage> createState() => _WeeklyMonthlySummaryPageState();
}

class _WeeklyMonthlySummaryPageState extends State<WeeklyMonthlySummaryPage> {
  final HealthService _healthService = HealthService();
  final EstimationService _estimationService = EstimationService(HealthService());
  FitnessGoal _goal = FitnessGoal.trend;

  bool _isLoading = false;
  bool _loadingEstimate = false;

  bool _isWeeklyView = true;
  DateTimeRange? _selectedWeek;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<int> _stepsData = const [];
  List<int> _caloriesData = const [];
  int _totalSteps = 0;
  int _totalCalories = 0;
  int _averageSteps = 0;
  int _averageCalories = 0;

  double? _weightKg;
  int? _heightCm;
  String? _gender;

  EstimationResult? _calorieEstimate;
  String? _estimateError;

  @override
  void initState() {
    super.initState();
    _healthService.connect();
    _selectedWeek = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );
    _loadProfile().then((_) async {
      await _fetchSummaryData(_selectedWeek!.start, _selectedWeek!.end);
      await _loadCalorieEstimation();
    });
  }

  DateTimeRange _monthlyRangeSmart(int year, int month) {
    final now = DateTime.now();

    if (year == now.year && month == now.month) {
      return DateTimeRange(
        start: DateTime(year, month, 1),
        end: now, // go up to now for current month
      );
    }

    final start = DateTime(year, month, 1);
    final nextMonth = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    // go up to the last moment of the month
    final end = nextMonth.subtract(const Duration(milliseconds: 1));
    return DateTimeRange(start: start, end: end);
  }


  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService().getCurrentProfile();
      if (profile != null) {
        _weightKg = (profile['weight_kg'] is num) ? (profile['weight_kg'] as num).toDouble() : null;
        _heightCm = (profile['height_cm'] is num) ? (profile['height_cm'] as num).toInt() : null;
        _gender = (profile['gender'] as String?)?.toLowerCase();
      }
    } catch (_) {}
  }

  double _strideMeters({int? heightCm, String? gender}) {
    final h = (heightCm ?? 170).toDouble();
    const factor = 0.415;
    return (h * factor) / 100.0;
  }

  List<int> _estimateCaloriesFromStepsDaily(List<int> dailySteps) {
    final weight = _weightKg ?? 70.0;
    final strideM = _strideMeters(heightCm: _heightCm, gender: _gender);
    const kcalPerKgKmWalking = 0.53;

    return List<int>.generate(dailySteps.length, (i) {
      final steps = dailySteps[i];
      final km = (steps * strideM) / 1000.0;
      final kcal = km * weight * kcalPerKgKmWalking;
      return kcal.round();
    });
  }

  List<int> _padOrTrim(List<int> list, int len) {
    if (list.length == len) return list;
    if (list.length > len) return list.sublist(0, len);
    return List<int>.from(list)..addAll(List.filled(len - list.length, 0));
  }

  Future<List<int>> _fetchBackendCaloriesSeries(DateTime start, DateTime end) async {
    try {
      final series = await WorkoutService().fetchDailyCaloriesSeries(from: start, to: end);
      final values = (series['values'] as List).map((e) {
        if (e is num) return e.round();
        return int.tryParse('$e') ?? 0;
      }).toList();
      return List<int>.from(values);
    } catch (_) {
      return [];
    }
  }

  Future<void> _fetchSummaryData(DateTime start, DateTime end) async {
    setState(() => _isLoading = true);

    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final dayCount = endDay.difference(startDay).inDays + 1;

    final totalSteps = await _healthService.getStepsInRange(startDay, endDay);
    final stepsDaily = await _healthService.getDailyStepsInRange(startDay, endDay);

    final stepsDailyFixed = _padOrTrim(stepsDaily, dayCount);
    final stepsCaloriesDaily = _estimateCaloriesFromStepsDaily(stepsDailyFixed);

    final backendCalories = await _fetchBackendCaloriesSeries(startDay, endDay);
    final backendFixed = _padOrTrim(backendCalories, dayCount);

    final mergedCalories = List<int>.generate(dayCount, (i) {
      final movement = stepsCaloriesDaily[i];
      return backendFixed[i] + movement;
    });

    final mergedTotalCalories = mergedCalories.fold<int>(0, (s, v) => s + v);
    final avgSteps = stepsDailyFixed.isNotEmpty
        ? (stepsDailyFixed.reduce((a, b) => a + b) ~/ stepsDailyFixed.length)
        : 0;
    final avgCalories = mergedCalories.isNotEmpty
        ? (mergedCalories.reduce((a, b) => a + b) ~/ mergedCalories.length)
        : 0;

    setState(() {
      _totalSteps = totalSteps;
      _stepsData = stepsDailyFixed;
      _totalCalories = mergedTotalCalories;
      _caloriesData = mergedCalories;
      _averageSteps = avgSteps;
      _averageCalories = avgCalories;
      _isLoading = false;
    });
  }

  Future<void> _loadCalorieEstimation() async {
    setState(() => _loadingEstimate = true);
    try {
      await _healthService.connect();
      final res = await _estimationService.buildCaloriesWeeklyEstimate(
        goal: _goal,
        weightKg: _weightKg,
        heightCm: _heightCm,
        gender: _gender,);
      setState(() {
        _calorieEstimate = res;
        _estimateError = null;
        _loadingEstimate = false;
      });
    } catch (e) {
      setState(() {
        _calorieEstimate = null;
        _estimateError = 'Failed to estimate: $e';
        _loadingEstimate = false;
      });
    }
  }

  double _calculateAdaptiveMaxY(List<int> data, double defaultMax,
      {double step = 2000, double headroom = 1.1, double maxCap = 50000}) {
    if (data.isEmpty) return defaultMax;
    final highest = data.reduce((a, b) => a > b ? a : b).toDouble();
    if (highest <= defaultMax) return defaultMax;
    final roundedUp = (((highest * headroom) / step).ceil()) * step;
    return roundedUp > maxCap ? maxCap : roundedUp;
  }

  double _calculateCaloriesMaxY(List<int> data, {int baseline = 300, int step = 100, int maxCap = 20000}) {
    if (data.isEmpty) return baseline.toDouble();
    final highest = data.reduce((a, b) => a > b ? a : b);
    if (highest <= baseline) return baseline.toDouble();
    final withHeadroom = highest + step;
    final roundedUp = ((withHeadroom / step).ceil()) * step;
    return roundedUp > maxCap ? maxCap.toDouble() : roundedUp.toDouble();
  }

  Widget _buildToggleTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.secondaryContainer,
      ),
      child: Row(
        children: [
          _toggleButton("Weekly", true, context),
          _toggleButton("Monthly", false, context),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isWeekly, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _isWeeklyView == isWeekly;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _isWeeklyView = isWeekly);
          if (isWeekly) {
            await _fetchSummaryData(_selectedWeek!.start, _selectedWeek!.end);
          } else {
            final range = _monthlyRangeSmart(_selectedYear, _selectedMonth);
            await _fetchSummaryData(range.start, range.end);
          }
          await _loadCalorieEstimation();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isWeeklyView) {
      return Column(
        children: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final picked = await showModalBottomSheet<DateTimeRange>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => WeekPickerDialog(initialRange: _selectedWeek),
                );
                if (picked != null) {
                  setState(() => _selectedWeek = picked);
                  await _fetchSummaryData(picked.start, picked.end);
                  await _loadCalorieEstimation();
                }
              },
              child: Text("Select Week", style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary)),
            ),
          ),
          if (_selectedWeek != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "${_selectedWeek!.start.day} ${_monthName(_selectedWeek!.start.month)} - "
                    "${_selectedWeek!.end.day} ${_monthName(_selectedWeek!.end.month)}",
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      );
    } else {
      final isLatestMonth = (_selectedYear == DateTime.now().year && _selectedMonth == DateTime.now().month);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colorScheme.primary),
            onPressed: () async {
              setState(() {
                _selectedMonth--;
                if (_selectedMonth < 1) {
                  _selectedMonth = 12;
                  _selectedYear--;
                }
              });
              final range = _monthlyRangeSmart(_selectedYear, _selectedMonth);
              await _fetchSummaryData(range.start, range.end);
              await _loadCalorieEstimation();
            },
          ),
          Text(
            "${_monthName(_selectedMonth)} $_selectedYear",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: isLatestMonth ? colorScheme.outline : colorScheme.primary),
            onPressed: isLatestMonth
                ? null
                : () async {
              setState(() {
                _selectedMonth++;
                if (_selectedMonth > 12) {
                  _selectedMonth = 1;
                  _selectedYear++;
                }
              });
              final range = _monthlyRangeSmart(_selectedYear, _selectedMonth);
              await _fetchSummaryData(range.start, range.end);
              await _loadCalorieEstimation();
            },
          ),
        ],
      );
    }
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    "Summary",
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildToggleTabs(context),
            const SizedBox(height: 12),
            _buildDatePicker(context),
            const SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: colorScheme.primary))
            else
              Expanded(
                child: ListView(
                  children: [
                    TimeBasedChart(
                      icon: Icons.directions_walk,
                      title: "Steps",
                      currentValue: "$_totalSteps",
                      avgValue: "$_averageSteps",
                      barColor: colorScheme.primary,
                      maxY: _calculateAdaptiveMaxY(_stepsData, 10000),
                      data: _stepsData,
                    ),
                    const SizedBox(height: 20),
                    TimeBasedChart(
                      icon: Icons.local_fire_department,
                      title: "Calories",
                      currentValue: "$_totalCalories kcal",
                      avgValue: "$_averageCalories kcal",
                      barColor: colorScheme.secondary,
                      maxY: _calculateCaloriesMaxY(_caloriesData),
                      data: _caloriesData,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Trend'),
                          labelStyle: Theme.of(context).textTheme.bodySmall, // smaller text
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          selected: _goal == FitnessGoal.trend,
                          onSelected: (_) => setState(() {
                            _goal = FitnessGoal.trend;
                            _loadCalorieEstimation();
                          }),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Weight Loss'),
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          selected: _goal == FitnessGoal.weightLoss,
                          onSelected: (_) => setState(() {
                            _goal = FitnessGoal.weightLoss;
                            _loadCalorieEstimation();
                          }),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Muscle Gain'),
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          selected: _goal == FitnessGoal.muscleGain,
                          onSelected: (_) => setState(() {
                            _goal = FitnessGoal.muscleGain;
                            _loadCalorieEstimation();
                          }),
                        ),
                      ],
                    ),
                    if (_loadingEstimate) ...[
                      const SizedBox(height: 12),
                      Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                    ] else if (_estimateError != null) ...[
                      const SizedBox(height: 12),
                      Text(_estimateError!, style: textTheme.bodyMedium),
                    ] else if (_calorieEstimate != null) ...[
                      const SizedBox(height: 12),
                      CalorieForecastCard(data: _calorieEstimate!), // <— use the widget
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalorieForecastCard extends StatelessWidget {
  final EstimationResult data;
  const _CalorieForecastCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allDates = [...data.datesActual, ...data.datesForecast];
    final nActual = data.datesActual.length;
    final totalPoints = allDates.length;

    final actualSpots = <FlSpot>[
      for (int i = 0; i < data.caloriesActual.length; i++)
        FlSpot(i.toDouble(), data.caloriesActual[i].toDouble())
    ];
    final forecastSpots = <FlSpot>[
      for (int i = 0; i < data.caloriesForecast.length; i++)
        FlSpot(nActual.toDouble() + i, data.caloriesForecast[i].toDouble())
    ];

    final allVals = [
      ...data.caloriesActual.map((e) => e.toDouble()),
      ...data.caloriesForecast.map((e) => e.toDouble())
    ];
    final maxY = (allVals.isEmpty ? 1000.0 : allVals.reduce((a, b) => a > b ? a : b)) * 1.15;

    final df = DateFormat('E');
    String xLabel(int i) => (i >= 0 && i < allDates.length) ? df.format(allDates[i]) : '';

    final pct = (data.trendPct * 100).toStringAsFixed(0);
    final trendingUp = data.trendPct > 0.02;
    final trendingDown = data.trendPct < -0.02;
    final chipColor = trendingUp ? Colors.green : (trendingDown ? Colors.red : Colors.orange);
    final chipText = trendingUp
        ? 'Trending up +$pct%'
        : trendingDown
        ? 'Trending down $pct%'
        : 'Flat ~$pct%';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.06), offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calories Forecast (7d)',
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Chip under the title so it never overflows
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: chipColor.withOpacity(.35)),
                ),
                child: Text(
                  chipText,
                  style: TextStyle(color: chipColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (totalPoints - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(.12), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: _niceTick(maxY / 4),
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: theme.textTheme.bodySmall),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        final label = xLabel(i);
                        if (label.isEmpty) return const SizedBox.shrink();
                        final isForecast = i >= nActual;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: isForecast ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isForecast ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final i = s.x.toInt();
                      final isForecast = i >= nActual;
                      final date = allDates[i];
                      return LineTooltipItem(
                        '${DateFormat('EEE, d MMM').format(date)}\n${isForecast ? "Forecast" : "Actual"}: ${s.y.toInt()} kcal',
                        TextStyle(
                          color: isForecast ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                rangeAnnotations: RangeAnnotations(
                  verticalRangeAnnotations: [
                    VerticalRangeAnnotation(
                      x1: nActual - 0.5,
                      x2: nActual - 0.5,
                      color: theme.colorScheme.primary.withOpacity(.15),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: theme.colorScheme.onSurface,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withOpacity(.08)),
                  ),
                  LineChartBarData(
                    spots: forecastSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: theme.colorScheme.primary,
                    dashArray: [8, 6],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withOpacity(.05)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Last 7d: ${data.last7Total} kcal', style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text('Next 7d (proj): ${data.next7TotalForecast} kcal',
                  style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }

  double _niceTick(double step) {
    if (step <= 0) return 1;
    final p = (math.log(step) / math.log(10)).floor();
    final base = step / math.pow(10, p);
    final nice = base <= 1 ? 1 : base <= 2 ? 2 : base <= 5 ? 5 : 10;
    return nice * math.pow(10, p).toDouble();
  }

}
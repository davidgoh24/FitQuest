import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Pulls EstimationResult + FitnessGoal types
import '../services/estimation_service.dart';

class CalorieForecastCard extends StatelessWidget {
  final EstimationResult data;
  const CalorieForecastCard({super.key, required this.data});

  String _modeLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.trend:
        return 'Trend';
      case FitnessGoal.weightLoss:
        return 'Weight loss';
      case FitnessGoal.muscleGain:
        return 'Muscle gain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel = _modeLabel(data.goal);
    final theme = Theme.of(context);
    final allDates = [...data.datesActual, ...data.datesForecast];
    final nActual = data.datesActual.length;
    final totalPoints = allDates.length;
    Color _getTrendColor(double trendPct) {
      if (trendPct > 0.02) return Colors.green;   // trending up
      if (trendPct < -0.02) return Colors.red;    // trending down
      return Colors.yellow;                       // flat
    }

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
      ...data.caloriesForecast.map((e) => e.toDouble()),
    ];
    final maxY = (allVals.isEmpty ? 1000.0 : allVals.reduce((a, b) => a > b ? a : b)) * 1.15;

    final df = DateFormat('E');
    String xLabel(int i) {
      if (i >= 0 && i < allDates.length) {
        return df.format(allDates[i]).substring(0, 1);
      }
      return '';
    }


    final pct = (data.trendPct * 100).toStringAsFixed(0);
    final trendingUp = data.trendPct > 0.02;
    final trendingDown = data.trendPct < -0.02;
    final chipColor = trendingUp ? Colors.green : (trendingDown ? Colors.red : Colors.orange);
    final chipText = trendingUp
        ? 'Trending up +$pct%'
        : trendingDown
        ? 'Trending down $pct%'
        : 'Flat ~$pct%';

    final guidance = _guidanceText(
      mode: data.goal,
      trendPct: data.trendPct,
      next7Avg: _safeAvg(data.caloriesForecast),
    );

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
          Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Calories Forecast (7d)',
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _modeLabel(data.goal), // Weight loss / Muscle gain / Trend
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: allDates.length * 20, // reduced spacing between points
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
                      getDrawingHorizontalLine: (v) =>
                          FlLine(color: Colors.grey.withOpacity(.12), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: _niceTick(maxY / 4),
                          getTitlesWidget: (v, _) =>
                              Text(v.toInt().toString(), style: theme.textTheme.bodySmall),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 20,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            final label = xLabel(i);
                            if (label.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Transform.rotate(
                                angle: -0.5,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  label,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: i >= nActual
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
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
                              color: isForecast
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
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
                        color: _getTrendColor(data.trendPct),
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _getTrendColor(data.trendPct).withOpacity(.08),
                        ),
                      ),
                      LineChartBarData(
                        spots: forecastSpots,
                        isCurved: true,
                        barWidth: 3,
                        color: _getTrendColor(data.trendPct),
                        dashArray: const [8, 6],
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _getTrendColor(data.trendPct).withOpacity(.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last 7d: ${data.last7Total} kcal',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Next 7d (proj): ${data.next7TotalForecast} kcal',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.info_outline,
            text: _whatThisShowsText(modeLabel),
          ),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.directions_run,
            text: guidance,
          ),
        ],
      ),
    );
  }

  // ---- helpers (widget-scope) ----

  static String _whatThisShowsText(String modeLabel) {
    return 'Shows your expected daily calorie burn for the next 7 days in $modeLabel mode.';
    // Keep short & friendly so it fits on mobile.
  }

  static String _guidanceText({
    required FitnessGoal mode,
    required double trendPct,
    required double next7Avg,
  }) {
    final trendWord = trendPct > 0.02 ? 'rising' : (trendPct < -0.02 ? 'falling' : 'steady');
    switch (mode) {
      case FitnessGoal.trend:
        return 'Keep your current routine. Activity looks $trendWord; if it dips, add a short walk or 10–15 min light cardio.';
      case FitnessGoal.weightLoss:
        return 'Aim to slightly increase activity this week. Add 2–3k steps/day or 20–30 min brisk cardio on 4–5 days.';
      case FitnessGoal.muscleGain:
        return 'Focus on strength 3×/week (e.g., Mon/Wed/Fri) and keep light activity on other days for recovery.';
    }
  }

  static double _safeAvg(List<int> xs) => xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

  static double _niceTick(double step) {
    if (step <= 0) return 1;
    final p = (math.log(step) / math.log(10)).floor();
    final base = step / math.pow(10, p);
    final nice = base <= 1 ? 1 : base <= 2 ? 2 : base <= 5 ? 5 : 10;
    return nice * math.pow(10, p).toDouble();
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

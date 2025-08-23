import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class TimeBasedChart extends StatelessWidget {
  final IconData icon;
  final String title;
  final String currentValue;
  final String avgValue;
  final Color barColor;
  final double maxY;
  final List<int> data;
  final double? maxYOverride;

  final bool adaptiveCalories;

  final int calorieBaseline;
  final int calorieStep;
  final int calorieMaxCap;

  const TimeBasedChart({
    super.key,
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.avgValue,
    required this.barColor,
    required this.maxY,
    required this.data,
    this.maxYOverride,
    this.adaptiveCalories = false,
    this.calorieBaseline = 300,
    this.calorieStep = 100,
    this.calorieMaxCap = 10000,
  });

  double _calculateAdaptiveMaxY(
      List<int> data, {
        double minY = 10000,
        double headroom = 1.1,
        double step = 2000,
        double maxCap = 50000,
      }) {
    if (data.isEmpty) return minY;
    final highest = data.reduce(math.max).toDouble();
    if (highest < minY) return minY;
    final roundedUp = (((highest * headroom) / step).ceil()) * step;
    return roundedUp > maxCap ? maxCap : roundedUp;
  }

  double _calculateCaloriesMaxY(
      List<int> data, {
        required int baseline,
        required int step,
        required int maxCap,
      }) {
    if (data.isEmpty) return baseline.toDouble();
    final highest = data.reduce(math.max);
    if (highest <= baseline) return baseline.toDouble();
    final withHeadroom = highest + step;
    final roundedUp = ((withHeadroom / step).ceil()) * step;
    return math.min(roundedUp, maxCap).toDouble();
  }

  String _formatYAxis(double value) {
    if (value >= 1000) return '${(value ~/ 1000)}k';
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final computedMaxY = maxYOverride ??
        (maxY > 0
            ? maxY
            : adaptiveCalories
            ? _calculateCaloriesMaxY(
          data,
          baseline: calorieBaseline,
          step: calorieStep,
          maxCap: calorieMaxCap,
        )
            : _calculateAdaptiveMaxY(data));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: barColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: barColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(currentValue, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Current", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
              Column(
                children: [
                  Text(avgValue, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Daily avg", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                minY: 0,
                maxY: computedMaxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text("${value.toInt() + 1}", style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: computedMaxY / 3,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(_formatYAxis(value), style: const TextStyle(fontSize: 10)),
                      ),
                      reservedSize: 34,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(
                  data.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].toDouble(),
                        color: barColor,
                        width: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

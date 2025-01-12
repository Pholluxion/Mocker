import 'dart:math' show max, min;

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:mocker/domain/domain.dart';

class DataDistributionChart extends StatelessWidget {
  const DataDistributionChart({
    super.key,
    required this.data,
    required this.color,
  });

  final List<Data> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    try {
      List<double> values = [];

      for (var d in data) {
        values.add(d.value.toDouble());
      }

      const int binCount = 10;
      final double minValue = values.reduce(min);
      final double maxValue = values.reduce(max);
      final double binSize = (maxValue - minValue) / binCount;

      final List<int> frequencies = List.filled(binCount, 0);

      for (var value in values) {
        int binIndex = ((value - minValue) / binSize).floor();
        if (binIndex == binCount) binIndex -= 1;
        frequencies[binIndex]++;
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          curve: Curves.easeInOut,
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(
              binCount,
              (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: frequencies[index].toDouble(),
                      color: color,
                      width: 20,
                    )
                  ],
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < binCount) {
                      final start = (minValue + value.toInt() * binSize).toStringAsFixed(1);
                      return Flexible(
                        child: Text(start, textAlign: TextAlign.center),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
        ),
      );
    } catch (e) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
  }
}

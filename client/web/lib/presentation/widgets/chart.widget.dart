import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class DataDistributionChart extends StatelessWidget {
  final List<Map<String, dynamic>> buffer;

  const DataDistributionChart({super.key, required this.buffer});

  @override
  Widget build(BuildContext context) {
    try {
      List<double> values = [];
      for (var map in buffer) {
        if (map['value'] is num) {
          values.add(map['value'].toDouble());
        }
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
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(binCount, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: frequencies[index].toDouble(),
                    color: Colors.blue,
                    width: 20,
                  )
                ],
              );
            }),
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

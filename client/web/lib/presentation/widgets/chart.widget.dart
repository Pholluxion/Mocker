import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

class ChartView extends StatefulWidget {
  const ChartView({
    super.key,
    required this.stream,
    required this.color,
  });

  final Stream<Data> stream;
  final MaterialColor color;

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> with AutomaticKeepAliveClientMixin {
  List<Data> buffer = [];
  late StreamSubscription<Data> _subscription;

  @override
  void initState() {
    _subscription = widget.stream.listen(
      (event) {
        setState(() {
          if (buffer.length > 1000) {
            buffer.removeAt(0);
          }

          buffer.add(event);
        });
      },
    );
    super.initState();
  }

  @override
  dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    try {
      List<double> values = [];

      if (buffer.isEmpty) {
        return const Card.outlined(
          margin: EdgeInsets.all(16),
          child: SizedBox.expand(),
        );
      }

      if (buffer.length < 5) {
        return const Card.outlined(
          margin: EdgeInsets.all(16),
          child: SizedBox.expand(
            child: Center(
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Loading chart...'),
                  CircularProgressIndicator.adaptive(),
                ],
              ),
            ),
          ),
        );
      }

      values = buffer.map((e) => (e.value as num).toDouble()).toList();

      values.sort();

      final Map<String, int> frequency = values.fold(
        <String, int>{},
        (Map<String, int> acc, double value) {
          final String key = value.toString();
          acc[key] = (acc[key] ?? 0) + 1;
          return acc;
        },
      );

      return Stack(
        children: [
          Builder(
            builder: (context) {
              final maxYValue = frequency.values.reduce(max);
              final minYValue = frequency.values.reduce(min);

              final spots = frequency.entries.map((e) => FlSpot(double.parse(e.key), e.value.toDouble())).toList();

              return LineChart(
                LineChartData(
                  minY: minYValue.toDouble(),
                  maxY: maxYValue.toDouble() + maxYValue.toDouble() * 0.2,
                  lineBarsData: [
                    LineChartBarData(
                      barWidth: 2,
                      spots: spots,
                      isCurved: true,
                      color: widget.color,
                      isStrokeCapRound: true,
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<ChartCubit, ChartState>(
                        builder: (context, state) {
                          return IconButton.filled(
                            onPressed: () {
                              if (state == ChartState.pause) {
                                _subscription.resume();
                                context.read<ChartCubit>().resume();
                              } else {
                                _subscription.pause();
                                context.read<ChartCubit>().pause();
                              }
                            },
                            icon: Icon(
                              state == ChartState.pause ? Icons.play_arrow : Icons.pause,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } catch (e) {
      return const Center(child: Text('Error loading chart'));
    }
  }

  @override
  bool get wantKeepAlive => true;
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

/// The detail page.
class DetailPage extends StatelessWidget {
  /// Construct the detail page.
  const DetailPage({super.key});

  /// The path for the detail page.
  static const String path = 'detail';

  /// The name for the detail page.
  static const String name = 'Detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MockCubit(
          GetIt.I.get<DocsRepository>(),
        )..getDocs(),
        child: const Card(
          child: ResizableWidget(),
        ),
      ),
    );
  }
}

// /// The detail modal page.
// class DetailModalPage extends StatelessWidget {
//   /// Construct the detail modal page.
//   const DetailModalPage({super.key});

//   /// The path for the detail modal page.
//   static const String path = 'detail-modal';

//   /// The name for the detail modal page.
//   static const String name = 'DetailModal';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detail Modal Page'),
//       ),
//       body: const Center(
//         child: Text('Detail modal Page'),
//       ),
//     );
//   }
// }

class ResizableWidget extends StatefulWidget {
  const ResizableWidget({super.key});
  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> with AutomaticKeepAliveClientMixin {
  double _dividerPosition = 0.65;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const dividerWidth = 16.0;

        final leftWidth = _dividerPosition * totalWidth - dividerWidth / 2;
        final rightWidth = totalWidth - leftWidth - dividerWidth;

        return Row(
          children: [
            Expanded(
              child:
                  VerticalResizableWidget(leftWidth: leftWidth, rightWidth: rightWidth, maxWidth: constraints.maxWidth),
            ),
            Visibility(
              visible: constraints.maxWidth > 600,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dividerPosition += details.delta.dx / totalWidth;
                    _dividerPosition = _dividerPosition.clamp(0.5, 0.7);
                  });
                },
                child: Container(
                  color: Colors.black12,
                  child: Center(
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: const Icon(
                        Icons.drag_handle,
                        size: dividerWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: constraints.maxWidth > Breakpoints.mediumAndUp.beginWidth!.toDouble(),
              child: SizedBox(
                width: rightWidth,
                child: const _SimulationForm(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SimulationForm extends StatefulWidget {
  const _SimulationForm();

  @override
  State<_SimulationForm> createState() => _SimulationFormState();
}

class _SimulationFormState extends State<_SimulationForm> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ControlPanel(),
          Gap(8),
          Expanded(child: MockForm()),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final user = context.watch<UserCubit>().state;
        final mock = context.watch<MockCubit>().state;
        return ExpansionTile(
          maintainState: true,
          title: const Text('Select a device'),
          subtitle: Text(
            mock.device?.deviceName ?? 'No device selected',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.devices),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedBackgroundColor: mock.device != null ? Colors.black12 : Colors.transparent,
          children: <Widget>[
            ...user.devices.map(
              (device) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    tileColor: Colors.black12,
                    title: Text(device.deviceName),
                    shape: device.deviceId == mock.device?.deviceId
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(width: 2),
                          )
                        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () => context.read<MockCubit>().setDevice(device),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}

class MockForm extends StatelessWidget {
  const MockForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const Text('Select a device', style: TextStyle(fontWeight: FontWeight.bold)),
            const DeviceTile(),
            BlocBuilder<MockCubit, MockState>(
              builder: (context, state) {
                if (state.device == null) {
                  return const SizedBox.shrink();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(flex: 1, child: Text('Name')),
                    Flexible(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(hintText: state.name.toString()),
                        onChanged: (value) => context.read<MockCubit>().setName(value),
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<MockCubit, MockState>(
              builder: (context, state) {
                if (state.device == null) {
                  return const SizedBox.shrink();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(flex: 1, child: Text('Interval (ms)')),
                    Flexible(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(hintText: state.intervalMs.toString()),
                        onChanged: (value) => context.read<MockCubit>().setIntervalMs(int.parse(value)),
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<MockCubit, MockState>(
              builder: (context, state) {
                if (state.device == null) {
                  return const SizedBox.shrink();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(flex: 2, child: Text('Enable MQTT')),
                    Flexible(
                      flex: 1,
                      child: Switch(
                        value: state.mqtt,
                        onChanged: (value) => context.read<MockCubit>().setMqtt(value),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Text('Select a method', style: TextStyle(fontWeight: FontWeight.bold)),
            BlocBuilder<MockCubit, MockState>(
              builder: (context, state) {
                return Column(
                  spacing: 8,
                  children: [
                    ...state.docs.map(
                      (doc) {
                        final fn = state.getFunction(doc.path);

                        return ExpansionTile(
                          enabled: fn.$1,
                          title: Text(doc.path),
                          subtitle: Text(doc.description),
                          collapsedBackgroundColor: fn.$1 ? Colors.black12 : Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          leading: Checkbox(
                            value: state.getFunction(doc.path).$1,
                            onChanged: state.device != null
                                ? (value) {
                                    debugPrint(value.toString());

                                    if (value == null) return;

                                    if (value) {
                                      context.read<MockCubit>().addFunction(doc);
                                    } else {
                                      context.read<MockCubit>().removeFunction(doc.path);
                                    }
                                  }
                                : null,
                          ),
                          children: <Widget>[
                            if (fn.$2 != null)
                              ...fn.$2!.parameters.map(
                                (param) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(flex: 1, child: Text(param.key)),
                                        Flexible(
                                          flex: 2,
                                          child: TextField(
                                            enabled: fn.$1,
                                            key: ValueKey(key),
                                            decoration: InputDecoration(hintText: param.value),
                                            onChanged: (value) => context.read<MockCubit>().updateFunctionParam(
                                                  fn.$2!.handler,
                                                  Param(
                                                    key: param.key,
                                                    value: value,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    )
                  ],
                );
              },
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockCubit, MockState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            IconButton.filled(
              tooltip: 'Run',
              onPressed: state.functions.isEmpty
                  ? null
                  : () {
                      if (state.parameters.any((element) => element.value.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all the parameters'),
                          ),
                        );
                        return;
                      }

                      context.read<MockCubit>().connect();
                    },
              icon: const Icon(Icons.play_arrow),
            ),
            IconButton.filled(
              tooltip: 'Stop',
              onPressed: state.functions.isEmpty ? null : () => context.read<MockCubit>().stop(),
              icon: const Icon(Icons.stop),
            ),
            IconButton.filled(
              tooltip: 'Show Raw Data',
              onPressed: state.functions.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                              width: 600,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  SourceCodeViewer<Mock>(data: state.getMock),
                                  IconButton.outlined(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
              icon: const Icon(Icons.share),
            ),
            IconButton.filled(
              tooltip: 'Clear',
              onPressed: state.functions.isEmpty ? null : () => context.read<MockCubit>().clear(),
              icon: const Icon(Icons.replay),
            ),
          ],
        );
      },
    );
  }
}

class VerticalResizableWidget extends StatefulWidget {
  const VerticalResizableWidget({
    super.key,
    required this.leftWidth,
    required this.rightWidth,
    required this.maxWidth,
  });

  final double leftWidth;
  final double rightWidth;
  final double maxWidth;

  @override
  State<VerticalResizableWidget> createState() => _VerticalResizableWidget();
}

class _VerticalResizableWidget extends State<VerticalResizableWidget> {
  double _dividerPosition = 0.7;
  late ScrollController _scrollController;
  late StreamSubscription _subscription;
  List<Map<String, dynamic>> buffer = [];
  int bufferLength = 10000;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _onData();
  }

  void addData(Map<String, dynamic> data) {
    buffer.add(data);
    if (buffer.length > bufferLength) {
      buffer.removeAt(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void _onData() {
    _subscription = context.read<MockCubit>().channel.stream.listen(
      (event) {
        setState(
          () {
            final data = json.decode(event);
            if (data is Map<String, dynamic> && data['values'] is List<dynamic>) {
              final list = data['values'] as List<dynamic>;

              for (final d in list) {
                addData(d);
              }
            } else {
              debugPrint('Invalid data format: $data');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        const dividerHeight = 16.0;

        final topHeight = _dividerPosition * totalHeight - dividerHeight / 2;
        final bottomHeight = totalHeight - topHeight - dividerHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<MockCubit, MockState>(
              builder: (context, state) {
                if (state.functions.isEmpty || buffer.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Icon(
                        Icons.stacked_bar_chart_outlined,
                        size: 64,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...state.functions.map(
                        (function) {
                          final name = function.getParam('name');
                          final bff = buffer.where((element) => element['name'] == name.value).toList();

                          final width = widget.maxWidth > 600 ? widget.leftWidth : widget.maxWidth;

                          return SizedBox(
                            width: width,
                            height: topHeight,
                            child: DataDistributionChart(buffer: bff),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dividerPosition += details.delta.dy / totalHeight;
                  _dividerPosition = _dividerPosition.clamp(0.3, 0.7);
                });
              },
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(
                    Icons.drag_handle,
                    size: dividerHeight,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: bottomHeight,
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: buffer.length,
                    itemBuilder: (context, index) {
                      final mock = context.read<MockCubit>().state;
                      return Text.rich(
                        TextSpan(
                          text: "${mock.name}: ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: buffer[index].toString(),
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              buffer.clear();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

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

      // Crear bins para el histograma
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

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

/// The detail modal page.
class DetailModalPage extends StatelessWidget {
  /// Construct the detail modal page.
  const DetailModalPage({super.key});

  /// The path for the detail modal page.
  static const String path = 'detail-modal';

  /// The name for the detail modal page.
  static const String name = 'DetailModal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Modal Page'),
      ),
      body: const Center(
        child: Text('Detail modal Page'),
      ),
    );
  }
}

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
              child: VerticalResizableWidget(
                leftWidth: leftWidth,
              ),
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

class _SimulationFormState extends State<_SimulationForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: Duration.zero,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Raw'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SizedBox.expand(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        BlocBuilder<MockCubit, SimulationState>(
                          builder: (context, state) {
                            if (state.function.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 8,
                              children: [
                                IconButton.filled(
                                  tooltip: 'Run',
                                  onPressed: () {
                                    ///validate the if any parameter is empty
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
                                  onPressed: () => context.read<MockCubit>().stop(),
                                  icon: const Icon(Icons.stop),
                                ),
                              ],
                            );
                          },
                        ),
                        const Text('Select a device', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Flexible(
                              child: BlocBuilder<UserCubit, UserState>(
                                builder: (context, state) {
                                  return DropdownButtonFormField<String>(
                                    value: null,
                                    items: state.devices.map(
                                      (device) {
                                        return DropdownMenuItem<String>(
                                          value: device.deviceId.toString(),
                                          child: Text(device.deviceName, overflow: TextOverflow.ellipsis),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        final device = state.devices.firstWhere((d) => d.deviceId.toString() == value);

                                        context.read<MockCubit>().setDevice(device);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Select a device',
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const Text('Select a method', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Flexible(
                              child: BlocBuilder<MockCubit, SimulationState>(
                                builder: (context, state) {
                                  return DropdownButtonFormField<String>(
                                    value: state.id.isEmpty ? null : state.id,
                                    items: state.docs.map(
                                      (doc) {
                                        return DropdownMenuItem<String>(
                                          value: doc.id,
                                          child: Text("${doc.path}/${doc.name}"),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        final doc = state.docs.firstWhere((doc) => doc.id == value);
                                        final params = doc.parameters
                                            .map(
                                              (param) => Param(key: param, value: ''),
                                            )
                                            .toList();
                                        context.read<MockCubit>()
                                          ..setId(doc.id)
                                          ..setPath(doc.path)
                                          ..setFunction(doc.name)
                                          ..setName(doc.name.toUpperCase())
                                          ..setDescription(doc.description)
                                          ..addParameters(params);
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Select a method',
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        BlocBuilder<MockCubit, SimulationState>(
                          builder: (context, state) {
                            if (state.parameters.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(state.description),
                                const Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                                const Divider(),
                                ...state.parameters.map(
                                  (param) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Text(param.key),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: BlocBuilder<MockCubit, SimulationState>(
                                            builder: (context, state) {
                                              return TextField(
                                                key: ValueKey(param.key),
                                                decoration: InputDecoration(hintText: param.value),
                                                onChanged: (value) {
                                                  final p = Param(key: param.key, value: value);
                                                  context.read<MockCubit>().updateParam(p);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        BlocBuilder<MockCubit, SimulationState>(
                          builder: (context, state) {
                            if (state.function.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  flex: 1,
                                  child: Text('Name'),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: state.name.toString(),
                                    ),
                                    onChanged: (value) {
                                      context.read<MockCubit>().setName(value);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        BlocBuilder<MockCubit, SimulationState>(
                          builder: (context, state) {
                            if (state.function.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  flex: 1,
                                  child: Text('Interval (ms)'),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: state.intervalMs.toString(),
                                    ),
                                    onChanged: (value) {
                                      context.read<MockCubit>().setIntervalMs(int.parse(value));
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        BlocBuilder<MockCubit, SimulationState>(
                          builder: (context, state) {
                            if (state.function.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  flex: 2,
                                  child: Text('Enable MQTT'),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Switch(
                                    value: state.mqtt,
                                    onChanged: (value) {
                                      context.read<MockCubit>().setMqtt(value);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<MockCubit, SimulationState>(
                builder: (context, state) {
                  return SourceCodeViewer<Mock>(data: state.getMock);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VerticalResizableWidget extends StatefulWidget {
  const VerticalResizableWidget({
    super.key,
    required this.leftWidth,
  });

  final double leftWidth;

  @override
  State<VerticalResizableWidget> createState() => _VerticalResizableWidget();
}

class _VerticalResizableWidget extends State<VerticalResizableWidget> {
  double _dividerPosition = 0.7;
  late ScrollController _scrollController;
  late StreamSubscription _subscription;
  List<Data> buffer = [];
  int bufferLength = 1000;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _onData();
  }

  void addData(Data data) {
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
        setState(() {
          final json = jsonDecode(event);
          final data = Data.fromJson(json);
          addData(data);
        });
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
            Builder(
              builder: (context) {
                if (buffer.isEmpty) {
                  return const Expanded(child: Center(child: Icon(Icons.stacked_bar_chart_outlined, size: 64)));
                }

                return Expanded(child: DataDistributionChart(data: buffer));
              },
            ),

            // Divisor redimensionable
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dividerPosition += details.delta.dy / totalHeight;
                  _dividerPosition = _dividerPosition.clamp(0.3, 0.7); // Limitar rango
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
            // Sección inferior
            SizedBox(
              height: bottomHeight,
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: buffer.length,
                    itemBuilder: (context, index) {
                      return Text("-> ${buffer[index].name} : ${buffer[index].value}");
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

class Data {
  final String name;
  final dynamic value;

  Data({required this.name, required this.value});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(name: json['name'], value: json['value']);
  }
}

class DataDistributionChart extends StatelessWidget {
  final List<Data> data;

  const DataDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    try {
      // Extraer los valores numéricos de la lista de datos
      final List<double> values = data.map((d) => d.value as double).toList();

      // Crear bins para el histograma
      const int binCount = 10;
      final double minValue = values.reduce(min);
      final double maxValue = values.reduce(max);
      final double binSize = (maxValue - minValue) / binCount;

      final List<int> frequencies = List.filled(binCount, 0);

      for (var value in values) {
        int binIndex = ((value - minValue) / binSize).floor();
        if (binIndex == binCount) binIndex -= 1; // Manejar caso borde
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
      return const SizedBox.shrink();
    }
  }
}

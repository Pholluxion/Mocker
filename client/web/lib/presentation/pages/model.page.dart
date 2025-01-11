import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

/// The mock page.
class MockPage extends StatelessWidget {
  /// Construct the detail page.
  const MockPage({super.key});

  /// The path for the detail page.
  static const String path = 'mock';

  /// The name for the detail page.
  static const String name = 'Mock';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => MockCubit(
          GetIt.I.get<DocsRepository>(),
        )..getDocs(),
        child: const MockView(),
      ),
    );
  }
}

class MockView extends StatelessWidget {
  const MockView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: constraints.maxWidth > 600,
              child: const VerticalDivider(),
            ),
            const Expanded(flex: 2, child: _ChartView()),
            Visibility(
              visible: constraints.maxWidth > 600,
              child: const VerticalDivider(),
            ),
            Visibility(
              visible: constraints.maxWidth > 600,
              child: const Expanded(flex: 1, child: _SimulationForm()),
            ),
          ],
        );
      },
    );
  }
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ControlPanel(),
          _MockForm(),
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

class _MockForm extends StatelessWidget {
  const _MockForm();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
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
        if (state.functions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconButton.filled(
              tooltip: 'Run',
              onPressed: () {
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
            IconButton.filled(
              tooltip: 'Show Raw Data',
              onPressed: () {
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
              onPressed: () => context.read<MockCubit>().clear(),
              icon: const Icon(Icons.replay),
            ),
          ],
        );
      },
    );
  }
}

class _ChartView extends StatefulWidget {
  const _ChartView();

  @override
  State<_ChartView> createState() => _VerticalResizableWidget();
}

class _VerticalResizableWidget extends State<_ChartView> {
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

                          return SizedBox(
                            width: constraints.maxWidth * 0.95,
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
                  Visibility(
                    visible: buffer.isNotEmpty,
                    child: Align(
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

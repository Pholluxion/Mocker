import 'package:flutter/material.dart';

import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

const colors = <MaterialColor>[
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.red,
  Colors.indigo,
  Colors.pink,
  Colors.blueGrey,
  Colors.orange,
  Colors.cyan,
  Colors.amber,
];

/// The mock page.
class MockPage extends StatelessWidget {
  /// Construct the detail page.
  const MockPage({super.key});

  /// The path for the detail page.
  static const String path = 'mock';

  /// The name for the detail page.
  static const String name = 'Mock';

  /// The server port.
  static const serverPort = int.fromEnvironment('SERVER_PORT', defaultValue: 8090);

  /// The server host.
  static const serverHost = String.fromEnvironment('SERVER_HOST', defaultValue: 'localhost');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        lazy: false,
        create: (context) => MockCubit(
          'ws://$serverHost:$serverPort/distribution',
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
            Expanded(
              flex: 2,
              child: BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return const AdaptiveWidget(
                    dividerPosition: 0.7,
                    topChild: _ChartView(),
                    bottomChild: _ConsoleView(),
                  );
                },
              ),
            ),
            Visibility(
              visible: constraints.maxWidth > 600,
              child: const VerticalDivider(),
            ),
            Visibility(
              visible: constraints.maxWidth > 600,
              child: const Expanded(
                flex: 1,
                child: _SimulationForm(),
              ),
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
                                              maxLength: 50,
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
                  AppDialog.info(
                    context: context,
                    title: 'Error in parameters',
                    content: 'Please fill all the parameters',
                  );
                  return;
                }

                context.read<MockCubit>().add();
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

class _ConsoleView extends StatefulWidget {
  const _ConsoleView();

  @override
  State<_ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<_ConsoleView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockCubit = context.watch<MockCubit>();
    return StreamBuilder<List<Data>>(
      stream: mockCubit.getData(),
      builder: (context, snapshot) {
        if (mockCubit.isBufferEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        final names = mockCubit.buffer.map((e) => e.name).toSet();

        final mapNameColor = names.fold<Map<String, Color>>(
          {},
          (previousValue, element) {
            final index = names.toList().indexOf(element);
            return previousValue..addAll({element: colors[index % colors.length]});
          },
        );

        return ListView.builder(
          controller: _scrollController,
          itemCount: mockCubit.buffer.length,
          itemBuilder: (context, index) {
            return Text(
              mockCubit.buffer[index].toString(),
              style: TextStyle(color: mapNameColor[mockCubit.buffer[index].name]),
            );
          },
        );
      },
    );
  }
}

class _ChartView extends StatelessWidget {
  const _ChartView();

  @override
  Widget build(BuildContext context) {
    final mockCubit = context.watch<MockCubit>();

    return StreamBuilder<List<Data>>(
      stream: mockCubit.getData(),
      builder: (context, snapshot) {
        if (mockCubit.state.functions.isEmpty || mockCubit.isBufferEmpty) {
          return const Center(child: Icon(Icons.bar_chart, size: 48));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final tabs = mockCubit.state.functions.fold<Map<int, TabData>>(
          {},
          (previousValue, element) {
            final name = element.getStringParam('name');

            if (!mockCubit.state.validateFunctionParams(element.handler)) {
              return previousValue;
            }
            final data = mockCubit.getDataByName(name);

            final names = mockCubit.buffer.map((e) => e.name).toSet();

            final mapNameColor = names.fold<Map<String, Color>>(
              {},
              (previousValue, element) {
                final index = names.toList().indexOf(element);
                return previousValue..addAll({element: colors[index % colors.length]});
              },
            );

            final tab = TabData(
              index: previousValue.length,
              title: Tab(text: name),
              content: DataDistributionChart(data: data, color: mapNameColor[name] ?? Colors.blue),
            );
            return previousValue..addAll({previousValue.length: tab});
          },
        );

        if (tabs.isEmpty) {
          return const Center(child: Icon(Icons.bar_chart, size: 48));
        }

        return DynamicTabBarWidget(
          isScrollable: true,
          nextIcon: const Icon(Icons.keyboard_double_arrow_right),
          backIcon: const Icon(Icons.keyboard_double_arrow_left),
          dynamicTabs: tabs.values.toList(),
          onTabControllerUpdated: (controller) {},
          onAddTabMoveTo: MoveToTab.idol,
        );
      },
    );
  }
}

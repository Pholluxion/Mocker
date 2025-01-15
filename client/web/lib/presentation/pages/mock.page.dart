import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => MockCubit(
            'ws://$serverHost:$serverPort/distribution',
            GetIt.I.get<DocsRepository>(),
          )..getDocs(),
        ),
        BlocProvider(
          create: (context) => ChartCubit(),
        ),
      ],
      child: const MockView(),
    );
  }
}

class MockView extends StatelessWidget {
  const MockView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 2,
                child: _ChartView(),
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
      ),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        final user = context.watch<UserCubit>();
                        final mock = context.watch<MockCubit>();

                        return MenuButton(
                          width: 200,
                          tooltip: 'Set device',
                          icon: const Icon(Icons.devices),
                          items: user.state.devices.map(
                            (device) {
                              return MenuItem(
                                text: device.deviceName,
                                icon: Icons.devices,
                                onPressed: (context) => mock.addDeviceParams(device),
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        if (!state.isDeviceIdPresent) {
                          return const Opacity(
                            opacity: 0.5,
                            child: Icon(CupertinoIcons.function),
                          );
                        }
                        return MenuButton(
                          width: 300,
                          tooltip: 'Add handler',
                          icon: const Icon(CupertinoIcons.function),
                          items: state.docs.map(
                            (doc) {
                              return MenuItem(
                                text: doc.path,
                                icon: CupertinoIcons.function,
                                onPressed: (context) {
                                  context.read<MockCubit>().addFunction(doc);
                                },
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        if (state.functions.isEmpty) {
                          return const Opacity(
                            opacity: 0.5,
                            child: Icon(Icons.tune),
                          );
                        }
                        return Tooltip(
                          message: 'Add custom parameter',
                          child: GestureDetector(
                            child: const Icon(Icons.tune),
                            onTap: () => context.read<MockCubit>().addCustomParam(Param(key: 'name', value: 'value')),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        return Tooltip(
                          message: 'Import',
                          child: GestureDetector(
                            onTap: context.read<MockCubit>().loadYaml,
                            child: const Icon(Icons.upload),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        if (state.functions.isEmpty) {
                          return const Opacity(
                            opacity: 0.5,
                            child: Icon(Icons.download),
                          );
                        }
                        return Tooltip(
                          message: 'Export',
                          child: GestureDetector(
                            onTap: context.read<MockCubit>().saveYaml,
                            child: const Icon(Icons.download),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        if (state.functions.isEmpty) {
                          return const Opacity(
                            opacity: 0.5,
                            child: Icon(Icons.refresh),
                          );
                        }
                        return Tooltip(
                          message: 'Reset',
                          child: GestureDetector(
                            onTap: context.read<MockCubit>().clear,
                            child: const Icon(Icons.refresh),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<MockCubit, MockState>(
                      builder: (context, state) {
                        if (state.functions.isEmpty) {
                          return const Opacity(
                            opacity: 0.5,
                            child: Icon(Icons.preview),
                          );
                        }
                        return Tooltip(
                          message: 'Preview',
                          child: GestureDetector(
                            onTap: () {
                              final state = context.read<MockCubit>().state;
                              AppDialog.showCodeViewer(mock: state.getMock, context: context);
                            },
                            child: const Icon(Icons.preview),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const _MockForm(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MockTile extends StatelessWidget {
  const MockTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockCubit, MockState>(
      builder: (context, state) {
        return Visibility(
          visible: state.functions.isNotEmpty,
          child: Column(
            spacing: 8,
            children: [
              ...state.functions.map(
                (fn) {
                  final fnName = fn.getStringParam('name');
                  final isEnabled = fn.enabled;

                  return ExpansionTile(
                    title: Text(fn.getStringParam('name')),
                    subtitle: Text(fn.handler),
                    leading: IconButton(
                      tooltip: 'Toggle simulation state',
                      onPressed: () {
                        final isValid = context.read<MockCubit>().toggleFunctionState(fnName);

                        if (!isValid) {
                          topSnackBar(context, 'Ups! The simulation $fnName is not valid, please check the parameters');
                        }
                      },
                      icon: Icon(isEnabled ? Icons.stop : Icons.play_arrow),
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove simulation',
                      onPressed: () => context.read<MockCubit>().removeFunction(fnName),
                      icon: const Icon(Icons.delete),
                    ),
                    initiallyExpanded: true,
                    collapsedBackgroundColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(width: 1),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(width: 1),
                    ),
                    children: <Widget>[
                      ...fn.parameters.map(
                        (param) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ParameterInputField(
                              enabled: !isEnabled,
                              param: param,
                              visible: true,
                              onChanged: (p) {
                                context.read<MockCubit>().updateFunctionParam(
                                      param.copyWith(value: p.value),
                                    );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              )
            ],
          ),
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
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.canEdit,
                    child: const Card.filled(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Icon(Icons.info_outline),
                              Text('Stop the simulation to edit the parameters'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.functions.isNotEmpty,
                    child: const Text('Simulation', style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
              const MockTile(),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.functions.isNotEmpty,
                    child: const Divider(),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.isDeviceIdPresent,
                    child: const Text('Default parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return ParameterCheckBox(
                    enabled: !state.canEdit,
                    visible: state.isDeviceIdPresent,
                    fieldName: 'MQTT',
                    onChanged: context.read<MockCubit>().setMqtt,
                    value: state.mqtt,
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return ParameterInputField(
                    enabled: !state.canEdit,
                    param: Param(key: 'intervalMs', value: '${state.intervalMs}'),
                    visible: state.isDeviceIdPresent,
                    onChanged: (p) => context.read<MockCubit>().setIntervalMs(p.value),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.isDeviceIdPresent,
                    child: const Divider(),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.isDeviceIdPresent,
                    child: const Text('Device parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.isDeviceIdPresent,
                    child: Column(
                      children: [
                        ...state.parameters.map(
                          (param) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ParameterInputField(
                                enabled: !state.canEdit,
                                param: param,
                                visible: true,
                                onChanged: context.read<MockCubit>().updateOrAddParam,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.customParameters.isNotEmpty,
                    child: const Divider(),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.customParameters.isNotEmpty,
                    child: const Text('Custom parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
              BlocBuilder<MockCubit, MockState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.customParameters.isNotEmpty,
                    child: Column(
                      children: [
                        ...state.customParameters.map(
                          (param) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CustomParameterInputField(
                                enabled: !state.canEdit,
                                param: param,
                                visible: true,
                                onChanged: context.read<MockCubit>().updateOrAddCustomParam,
                                onRemove: context.read<MockCubit>().removeCustomParam,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

class _ChartView extends StatelessWidget {
  const _ChartView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockCubit, MockState>(
      builder: (context, state) {
        final enabled = state.functions.where((element) => element.enabled).toList();

        List<TabData> tabs = enabled.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final function = entry.value;
            final name = function.getStringParam('name');
            final color = colors[index % colors.length];
            return TabData(
              index: index,
              title: Tab(child: Text(name)),
              content: _ChartTab(name: name, color: color),
            );
          },
        ).toList();

        if (tabs.isEmpty) {
          return const Center(child: Icon(Icons.bar_chart, size: 48));
        }
        return DynamicTabBarWidget(
          isScrollable: true,
          nextIcon: const Icon(Icons.keyboard_double_arrow_right),
          backIcon: const Icon(Icons.keyboard_double_arrow_left),
          dynamicTabs: tabs,
          onTabControllerUpdated: (controller) {},
          onTabChanged: (p0) {},
        );
      },
    );
  }
}

class _ChartTab extends StatelessWidget {
  const _ChartTab({
    required this.name,
    required this.color,
  });

  final String name;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWidget(
      dividerPosition: 0.5,
      topChild: ChartView(
        stream: context.read<MockCubit>().getDataByName(name),
        color: color,
      ),
      bottomChild: ConsoleView(
        stream: context.read<MockCubit>().getDataByName(name),
        color: color,
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> topSnackBar(BuildContext context, String message) {
  final size = MediaQuery.sizeOf(context);

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
      margin: EdgeInsets.only(
        top: size.height * 0.9,
        right: size.width * 0.8,
        bottom: 16.0,
        left: 16.0,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

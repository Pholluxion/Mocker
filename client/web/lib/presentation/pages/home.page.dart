import 'package:flutter/material.dart';

import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:mocker/presentation/presentation.dart';

/// The detail overview page.
class HomePage extends StatefulWidget {
  /// Construct the detail overview page.
  const HomePage({super.key});

  /// The path for the detail page.
  static const String path = '/home';

  /// The name for the detail page.
  static const String name = 'Home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TabData> tabs = [];

  void removeTab(int id) {
    setState(() {
      tabs.removeAt(id);
    });
  }

  void addTab() {
    setState(() {
      var tabNumber = tabs.length + 1;
      tabs.add(
        TabData(
          index: tabNumber,
          title: Tab(
              child: Row(
            children: [
              Text('Simulation $tabNumber'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => removeTab(tabNumber - 1),
              ),
            ],
          )),
          content: DetailPage(key: UniqueKey()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        shape: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        actions: [
          if (tabs.isNotEmpty)
            OutlinedButton(
              onPressed: addTab,
              child: const Text("New Simulation"),
            ),
          BlocBuilder<ThemeCubit, bool>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state ? Icons.light_mode : Icons.dark_mode),
                onPressed: context.read<ThemeCubit>().toggle,
              );
            },
          ),
          const Gap(8),
        ],
      ),
      body: Builder(builder: (context) {
        if (tabs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(8),
                IconButton.filledTonal(
                  onPressed: addTab,
                  icon: const Icon(Icons.add, size: 64),
                ),
              ],
            ),
          );
        }

        return DynamicTabBarWidget(
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          tabAlignment: TabAlignment.start,
          dynamicTabs: tabs,
          onTabControllerUpdated: (controller) {
            debugPrint("onTabControllerUpdated");
          },
          onTabChanged: (index) {
            debugPrint("Tab changed: $index");
          },
        );
      }),
    );
  }
}

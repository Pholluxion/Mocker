import 'package:flutter/material.dart';

import 'package:mocker/presentation/presentation.dart';

/// The detail overview page.
class HomePage extends StatelessWidget {
  /// Construct the detail overview page.
  const HomePage({super.key});

  /// The path for the detail page.
  static const String path = '/home';

  /// The name for the detail page.
  static const String name = 'Home';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TabView(),
    );
  }
}

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  Map<int, TabData> tabs = {};

  void removeTab(int id) => setState(() => tabs.remove(id));

  void addTab() => setState(
        () {
          final key = tabs.length + 1;
          final tab = TabData(
            index: key,
            title: buildTabTitle(key),
            content: MockPage(key: UniqueKey()),
          );
          tabs.addAll({key: tab});
        },
      );

  Tab buildTabTitle(int key) {
    return Tab(
      child: Row(
        children: [
          Text('Simulation $key'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => removeTab(key),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (tabs.isEmpty) {
          return Center(
            child: IconButton.filledTonal(
              tooltip: 'New simulation',
              onPressed: addTab,
              icon: const Icon(Icons.add, size: 64),
            ),
          );
        }

        return DynamicTabBarWidget(
          isScrollable: true,
          enableFeedback: true,
          trailing: addTabBtn(),
          nextIcon: const Icon(Icons.keyboard_double_arrow_right),
          backIcon: const Icon(Icons.keyboard_double_arrow_left),
          indicatorSize: TabBarIndicatorSize.tab,
          tabAlignment: TabAlignment.start,
          dynamicTabs: tabs.values.toList(),
          onTabControllerUpdated: (controller) {},
          onTabChanged: (index) {},
        );
      },
    );
  }

  IconButton addTabBtn() {
    return IconButton(
      tooltip: 'New simulation',
      onPressed: addTab,
      icon: const Icon(Icons.add),
    );
  }
}

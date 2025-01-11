import 'package:flutter/material.dart';

import 'package:mocker/presentation/presentation.dart';

/// The settings page.
class SettingsPage extends StatelessWidget {
  /// Construct the settings page.
  const SettingsPage({super.key});

  /// The path for the settings page.
  static const String path = '/settings';

  /// The name for the settings page.
  static const String name = 'Settings';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: ThemeButton()),
    );
  }
}

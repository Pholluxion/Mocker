import 'package:flutter/material.dart';

import 'package:mocker/core/core.dart';

/// The profile page.
class ProfilePage extends StatelessWidget {
  /// Construct the profile page.
  const ProfilePage({super.key});

  /// The path for the profile page.
  static const String path = '/profile';

  /// The name for the profile page.
  static const String name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => <void>{
                AppRouter.authenticatedNotifier.value = false,
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

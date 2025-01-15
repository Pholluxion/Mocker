import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import 'package:mocker/presentation/presentation.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

class AppRouter {
  static ValueNotifier<bool> authenticatedNotifier = ValueNotifier<bool>(false);

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: NavigationErrorPage());
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/') {
        return HomePage.path;
      }
      return null;
    },
    refreshListenable: authenticatedNotifier,
    routes: <RouteBase>[
      _unauthenticatedRoutes,
      _authenticatedRoutes,
    ],
  );

  static final GoRoute _unauthenticatedRoutes = GoRoute(
    name: LoginPage.name,
    path: LoginPage.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: LoginPage());
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (authenticatedNotifier.value) {
        return HomePage.path;
      }
      return null;
    },
  );

  static final StatefulShellRoute _authenticatedRoutes = StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder: (
      BuildContext context,
      GoRouterState state,
      StatefulNavigationShell navigationShell,
    ) {
      return ScaffoldShell(navigationShell: navigationShell);
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (!authenticatedNotifier.value) {
        return LoginPage.path;
      }
      return null;
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        navigatorKey: _homeNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            name: HomePage.name,
            path: HomePage.path,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(
                child: HomePage(),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                name: MockPage.name,
                path: MockPage.path,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const MaterialPage<void>(
                    child: MockPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _profileNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            path: ProfilePage.path,
            name: ProfilePage.name,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(child: ProfilePage());
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _settingsNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            name: SettingsPage.name,
            path: SettingsPage.path,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage<void>(child: SettingsPage());
            },
          ),
        ],
      ),
    ],
  );
}

class ScaffoldShell extends StatelessWidget {
  const ScaffoldShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useDrawer: false,
      transitionDuration: Duration.zero,
      body: (BuildContext context) => navigationShell,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: (int index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: navigationShell.route.branches.map(
        (StatefulShellBranch e) {
          return switch (e.defaultRoute?.name) {
            HomePage.name => const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            ProfilePage.name => const NavigationDestination(icon: Icon(Icons.account_circle), label: 'Profile'),
            SettingsPage.name => const NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            _ => throw UnimplementedError('The route ${e.defaultRoute?.name} is not implemented.'),
          };
        },
      ).toList(),
    );
  }
}

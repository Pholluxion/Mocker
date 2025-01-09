import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import 'package:mocker/core/core.dart';
import 'package:mocker/domain/domain.dart';
import 'package:mocker/presentation/presentation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const AppRoot());
}

/// The main application widget for this example.
class AppRoot extends StatelessWidget {
  /// Creates a const main application widget.
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(
            GetIt.I.get<UserRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: const MockerApp(),
    );
  }
}

class MockerApp extends StatelessWidget {
  const MockerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'Mocker',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('en', 'US'),
      ],
      themeMode: context.select((ThemeCubit cubit) => cubit.state ? ThemeMode.dark : ThemeMode.light),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}

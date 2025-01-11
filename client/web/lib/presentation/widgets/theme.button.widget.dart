import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocker/presentation/presentation.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return IconButton(
          tooltip: 'Toggle theme mode to ${state ? 'dark' : 'light'}',
          icon: Icon(state ? Icons.light_mode : Icons.dark_mode),
          onPressed: context.read<ThemeCubit>().toggle,
        );
      },
    );
  }
}

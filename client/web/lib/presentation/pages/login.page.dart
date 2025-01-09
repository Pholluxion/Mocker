import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:mocker/core/core.dart';
import 'package:mocker/presentation/presentation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  /// The path for the login page.
  static const String path = '/login';

  /// The name for the login page.
  static const String name = 'Login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _usernameController = TextEditingController(
      text: 'Pholluxion',
    );
    _passwordController = TextEditingController(
      text: 'qwerty',
    );
    super.initState();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void validate() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Por favor, rellene todos los campos.'),
            actions: [
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } else {
      await context.read<UserCubit>().signIn(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.user.isValid) {
          AppRouter.authenticatedNotifier.value = true;
        } else {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Inicio de sesión incorrecto.'),
                actions: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        body: CupertinoAlertDialog(
          title: const Text('Bienvenido'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoButton.filled(
                onPressed: () => validate(),
                child: const Text('Iniciar sesión'),
              ),
            ),
          ],
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Por favor, complete los siguientes campos para iniciar sesión.',
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                const Text('Nombre de usuario'),
                CupertinoTextField(
                  maxLength: 50,
                  controller: _usernameController,
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(CupertinoIcons.person),
                  ),
                  placeholder: 'admin',
                  style: const TextStyle(color: Colors.grey),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Text('Contraseña'),
                CupertinoTextField(
                  maxLength: 50,
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: togglePasswordVisibility,
                      child: Icon(
                        _isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      ),
                    ),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(CupertinoIcons.lock),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  placeholder: '******',
                  style: const TextStyle(color: Colors.grey),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

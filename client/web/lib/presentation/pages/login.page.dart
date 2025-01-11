import 'dart:async';

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
  late final ValueNotifier<bool> _isPasswordVisible;

  @override
  void initState() {
    //TODO: Remove this line
    _usernameController = TextEditingController(
      text: 'Pholluxion',
    );
    //TODO: Remove this line
    _passwordController = TextEditingController(
      text: 'qwerty',
    );

    _isPasswordVisible = ValueNotifier<bool>(false);
    super.initState();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  void validate() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      AppDialog.info(
        title: 'Ups! Something went wrong',
        content: 'Please, check your credentials and try again.',
        context: context,
      );
      return;
    }
    unawaited(context.read<UserCubit>().signIn(username, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.user.isValid) {
          AppRouter.authenticatedNotifier.value = true;
        } else {
          AppDialog.info(
            title: 'Ups! Something went wrong',
            content: 'Please, check your credentials and try again.',
            context: context,
          );
        }
      },
      child: Scaffold(
        body: CupertinoAlertDialog(
          title: const Text('Welcome'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoButton.filled(
                onPressed: () => validate(),
                child: const Text('Sign In'),
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
                  'Complete the following fields to sign in.',
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                const Text('Username'),
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
                const Text('Password'),
                ListenableBuilder(
                  listenable: _isPasswordVisible,
                  builder: (context, child) {
                    return CupertinoTextField(
                      maxLength: 50,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible.value,
                      suffix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: togglePasswordVisibility,
                          child: Icon(
                            _isPasswordVisible.value ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

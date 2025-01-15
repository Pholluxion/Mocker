import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

import 'package:mocker/presentation/presentation.dart';

abstract class AppDialog {
  static Future<T?> confirm<T>({
    required String title,
    required String content,
    required VoidCallback? onConfirm,
    required VoidCallback? onCancel,
    required BuildContext context,
  }) =>
      showCupertinoDialog<T>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              CupertinoButton(
                onPressed: onConfirm,
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

  static Future<T?> info<T>({
    required String title,
    required String content,
    required BuildContext context,
  }) =>
      showCupertinoDialog<T>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Accept'),
              ),
            ],
          );
        },
      );

  static Future<T?> showCodeViewer<T>({
    required Mock mock,
    required BuildContext context,
  }) =>
      showDialog<T>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: 600,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  SourceCodeViewer<Mock>(data: mock),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
}

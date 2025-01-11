import 'package:flutter/cupertino.dart';

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
}

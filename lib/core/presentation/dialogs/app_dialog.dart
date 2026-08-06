import 'package:flutter/material.dart';
import 'package:segadi/core/presentation/dialogs/confirmation_dialog.dart';
import 'package:segadi/core/presentation/dialogs/loading_dialog.dart';
import 'package:segadi/core/presentation/dialogs/message_dialog.dart';

class AppDialog {
  const AppDialog._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

    return result ?? false;
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MessageDialog(
        title: title,
        message: message,
        isSuccess: true,
      ),
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MessageDialog(
        title: title,
        message: message,
        isSuccess: false,
      ),
    );
  }

  static void loading(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(),
    );
  }

  static void close(
    BuildContext context,
  ) {
    Navigator.pop(context);
  }
}

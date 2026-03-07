import 'package:flutter/material.dart';

void showErrorModal(
  BuildContext context,
  String message,
  VoidCallback onRetry,
) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          const Text('Ha ocurrido un error',
              style: TextStyle(
                fontSize: 18,
              )),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

class ErrorModalLauncher extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorModalLauncher({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<ErrorModalLauncher> createState() => _ErrorModalLauncherState();
}

class _ErrorModalLauncherState extends State<ErrorModalLauncher> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_shown) {
      _shown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorModal(
          context,
          widget.message,
          widget.onRetry,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // No mostramos nada en pantalla
    return const SizedBox.shrink();
  }
}

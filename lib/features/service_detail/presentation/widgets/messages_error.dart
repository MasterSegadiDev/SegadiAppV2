import 'package:flutter/cupertino.dart';

void showErrorModal(
  BuildContext context,
  String message,
  VoidCallback onRetry,
) {
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: const Text('Ha ocurrido un error'),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            onRetry();
          },
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

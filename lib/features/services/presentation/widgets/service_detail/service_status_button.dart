import 'package:flutter/material.dart';

class ServiceStatusButton extends StatelessWidget {
  final String status;
  final bool enabled;
  final VoidCallback? onPressed;

  const ServiceStatusButton({
    super.key,
    required this.status,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: Text(
          status,
        ),
      ),
    );
  }
}

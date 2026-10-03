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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E7A3C),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0DA),
          disabledForegroundColor: const Color(0xFF9A9A94),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

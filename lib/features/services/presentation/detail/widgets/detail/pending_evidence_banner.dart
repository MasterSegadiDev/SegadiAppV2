import 'package:flutter/material.dart';

class PendingEvidenceBanner extends StatelessWidget {
  final VoidCallback onContinue;

  const PendingEvidenceBanner({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Evidencias faltantes. Debe finalizar la remisión.',
              style: TextStyle(
                color: Color(0xFF856404),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onContinue,
            child: const Text(
              'CONTINUAR',
              style: TextStyle(
                color: Color(0xFF2C522A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PendingEvidenceBanner extends StatelessWidget {
  final VoidCallback onContinue;

  const PendingEvidenceBanner({
    super.key,
    required this.onContinue,
  });

  static const _primaryGreen = Color(0xFF1E7A3C);
  static const _textPrimary = Color(0xFF101812);
  static const _textSecondary = Color(0xFF6B6B66);

  static const _warning = Color(0xFFE49B18);
  static const _warningSoft = Color(0xFFFFF7E6);
  static const _warningBorder = Color(0xFFF1D7A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _warningSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _warningBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onContinue,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icono
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _warning.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: _warning,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                // Información
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evidencias pendientes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Completa las evidencias para finalizar la remisión.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Acción
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
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

import 'package:flutter/material.dart';

class ServiceHeaderCard extends StatelessWidget {
  final String serviceNumber;

  const ServiceHeaderCard({
    super.key,
    required this.serviceNumber,
  });

  static const _green = Color(0xFF1E7A3C);
  static const _greenSoft = Color(0xFFE1F0E3);
  static const _dark = Color(0xFF101812);
  static const _secondary = Color(0xFF6B6B66);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _dark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: _greenSoft,
              child: const Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: _green,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'REMISIÓN ASIGNADA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                      color: _dark,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _greenSoft,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 20,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Número de remisión',
                          style: TextStyle(
                            fontSize: 11,
                            color: _secondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          serviceNumber,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

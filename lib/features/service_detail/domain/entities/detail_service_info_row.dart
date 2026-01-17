import 'package:flutter/cupertino.dart';

class InfoRow {
  final IconData icon; // ✅ el de Flutter
  final String label;
  final String value;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

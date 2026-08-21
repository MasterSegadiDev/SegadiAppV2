import 'package:flutter/material.dart';

class ServiceActionItem {
  final String key;
  final String title;
  final IconData icon;
  final bool enabled;
  final bool show;

  const ServiceActionItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.enabled,
    required this.show,
  });
}

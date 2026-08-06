import 'package:flutter/material.dart';

class ServiceActionItem {
  final String key;
  final String title;
  final IconData icon;

  final bool show;
  final bool enabled;

  final VoidCallback? onTap;

  const ServiceActionItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.show,
    required this.enabled,
    this.onTap,
  });
}

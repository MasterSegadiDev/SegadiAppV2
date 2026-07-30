import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceActionItem {
  final String id;
  final String title;
  final FaIconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const ServiceActionItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.enabled,
    this.onTap,
  });
}

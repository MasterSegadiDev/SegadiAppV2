import 'package:flutter/material.dart';

class MenuOption {
  final IconData icon;
  final String label;
  final String permission;
  final Function(BuildContext) onTap;

  const MenuOption({
    required this.icon,
    required this.label,
    required this.permission,
    required this.onTap,
  });
}

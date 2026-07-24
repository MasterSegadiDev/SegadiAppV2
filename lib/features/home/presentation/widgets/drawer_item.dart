import 'package:flutter/material.dart';

class DrawerItem {
  final String title;

  final IconData icon;

  final String route;

  final bool visible;

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.visible,
  });
}

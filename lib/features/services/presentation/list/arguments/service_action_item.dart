import 'package:flutter/material.dart';

import 'package:segadi/features/services/domain/enums/service_action.dart';

class ServiceActionItem {
  final ServiceAction key;
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

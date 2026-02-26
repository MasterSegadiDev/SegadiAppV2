import 'package:flutter/material.dart';

class DetailHeader extends StatelessWidget {
  final String service;

  const DetailHeader({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Text(
      'REMISIÓN $service',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

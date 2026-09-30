import 'package:flutter/material.dart';

class ServicesLoading extends StatelessWidget {
  const ServicesLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

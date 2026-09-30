import 'package:flutter/material.dart';

class ServicesEmpty extends StatelessWidget {
  const ServicesEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No tienes servicios asignados.',
      ),
    );
  }
}

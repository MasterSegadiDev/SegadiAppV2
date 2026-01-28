import 'package:flutter/material.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';
import 'package:segadi/presentation/design_system/components/cards/app_list_card.dart';
import 'package:segadi/presentation/design_system/theme/app_body.dart';
import 'package:segadi/presentation/design_system/theme/app_header.dart';

class MovimientoCard extends StatelessWidget {
  final ContainerMovement movimiento;
  final String? contenedorMover;
  final VoidCallback? onTap;

  const MovimientoCard({
    required this.movimiento,
    required this.contenedorMover,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      onTap: onTap,
      header: Header(movimiento, contenedorMover),
      body: Body(movimiento),
    );
  }
}

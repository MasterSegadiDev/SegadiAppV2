import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

class MapaUbicacionesWidget extends StatelessWidget {
  final String tipoMovimiento;
  final String? movementId;
  final String? areaInicial;
  final String? espacioInicial;
  final String? nivelInicial;

  const MapaUbicacionesWidget({
    super.key,
    required this.tipoMovimiento,
    required this.movementId,
    this.areaInicial,
    this.espacioInicial,
    this.nivelInicial,
    required UbicacionesViewModel vm,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesViewModel>();

    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.error != null) return Center(child: Text(vm.error!));

    // Aquí debes dibujar tu mapa (áreas/espacios) como ya lo hacías,
    // pero IMPORTANTÍSIMO: en los onTap NO debes decidir reglas;
    // solo llamas a callbacks del VM (o a un "flow" que tengas).
    return const Center(
        child: Text('Mapa (UI limpia) - aquí va tu layout de áreas'));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/widgets/widgetContainerMapManzanillo.dart';

class ContainerRearrangementScreen extends StatefulWidget {
  final String
      tipoMovimiento; // canónico: 'pisocamion'|'camionpiso'|'reacomodo'
  final String tipoMovimientoPantalla; // cadena para mostrar en AppBar
  final String? movementId;

  const ContainerRearrangementScreen({
    Key? key,
    required this.tipoMovimiento,
    required this.tipoMovimientoPantalla,
    this.movementId,
  }) : super(key: key);

  @override
  State<ContainerRearrangementScreen> createState() =>
      _ContainerRearrangementScreenState();
}

class _ContainerRearrangementScreenState
    extends State<ContainerRearrangementScreen> {
  late UbicacionesViewModel vm;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vmWatch = Provider.of<UbicacionesViewModel>(context);
    final movementVm = Provider.of<ContainerMovementListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Movimiento - ${widget.tipoMovimientoPantalla.toUpperCase()}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C522A),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // ← flecha blanca
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),

          // Mapa ORIGINAL (no se modifica nada)
          Expanded(
            child: MapaUbicacionesWidget(
              movementId: widget.movementId,
              vm: vmWatch,
              tipoMovimiento: widget.tipoMovimiento,
              areaInicial: movementVm.selectedInitialArea,
              espacioInicial: movementVm.selectedInitialEspacio,
              nivelInicial: movementVm.selectedInitialNivel,
            ),
          ),
        ],
      ),
    );
  }
}

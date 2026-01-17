import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/widgets/widgetContainerRearrangement.dart';
import 'package:segadi/views/container_movements/widgets/widgetWeightContainer.dart';

class MovementTypes {
  static const String pisoCamion = 'pisocamion';
  static const String camionPiso = 'camionpiso';
  static const String reacomodo = 'reacomodo';
}

class ContainersMapScreen extends StatefulWidget {
  const ContainersMapScreen({super.key});

  @override
  State<ContainersMapScreen> createState() => _ContainersMapScreenState();
}

class _ContainersMapScreenState extends State<ContainersMapScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        setState(() {
          _error =
              "No se encontró un site_id válido. Inicie sesión nuevamente.";
          _isLoading = false;
        });
        return;
      }

      await _loadUbicaciones();
    });
  }

  Future<void> _loadUbicaciones() async {
    try {
      final vm = Provider.of<UbicacionesViewModel>(context, listen: false);
      await vm.cargarUbicacionesDesdeApi();
    } catch (e) {
      _error = 'Error al cargar ubicaciones';
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movementVm = Provider.of<ContainerMovementListViewModel>(context);

    final movementType = movementVm.selectedMovementType;
    final movementId = movementVm.selectedMovementId;
    final containerNumber = movementVm.selectedContainerNumber;
    final status = movementVm.selectedStatus;

    // ----------- Estado inicial ----------
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2C522A),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    print("📌 Tipo movimiento: $movementType");
    print("📌 ID movimiento: $movementId");
    print("📌 Contenedor: $containerNumber");
    print("📌 Estatus: $status");

    // ----------- Routing dinámico ----------
    switch (movementType) {
      case 'Piso-Camion':
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.pisoCamion,
          tipoMovimientoPantalla: "Piso - Camión",
          movementId: movementId!,
        );

      case 'Camion-Piso':
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.camionPiso,
          tipoMovimientoPantalla: "Camión - Piso",
          movementId: movementId!,
        );

      case 'Reacomodo':
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.reacomodo,
          tipoMovimientoPantalla: "Reacomodo",
          movementId: movementId!,
        );

      case 'Pesaje':
        return PesajeFormScreen(
          movementId: movementId!,
          serie: containerNumber,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text(
              'Tipo de movimiento no soportado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }
}

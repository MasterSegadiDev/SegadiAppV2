import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/contenedores/movimientosContenedoresListadoViewModel.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

import 'package:segadi/views/contenedores/mapas_contenedor/widgets/mapaCentralWidget.dart';
import 'package:segadi/views/contenedores/mapas_contenedor/widgets/formularioPesajeWidget.dart';

/// Tipos de movimiento soportados
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
    _initialize();
  }

  /// Inicialización limpia y profesional
  Future<void> _initialize() async {
    final session = UserSession();
    await session.loadFromPrefs();

    if (!mounted) return;

    if (session.siteId.isEmpty) {
      setState(() {
        _error = "No se encontró un site_id válido. Inicie sesión nuevamente.";
        _isLoading = false;
      });
      return;
    }

    await _loadUbicaciones();
  }

  /// Carga de ubicaciones desde API
  Future<void> _loadUbicaciones() async {
    try {
      final ubicacionesVM =
          Provider.of<UbicacionesViewModel>(context, listen: false);

      await ubicacionesVM.cargarUbicaciones("2");
    } catch (e) {
      _error = 'Error al cargar ubicaciones';
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  //==========================================================
  //  WIDGET ROOT
  //==========================================================
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<movimientosContenedoresListadoViewModel>();

    final movementType = vm.selectedMovementType;
    final movementId = vm.selectedMovementId;
    final containerNumber = vm.selectedContainerNumber;

    // ========== ESTADOS DE CARGA ==========
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(_error!)),
      );
    }

    // Log para debugging
    debugPrint("📌 Tipo movimiento: $movementType");
    debugPrint("📌 ID movimiento: $movementId");
    debugPrint("📌 Contenedor: $containerNumber");

    // ========== ROUTING DINÁMICO ==========
    return _buildScreenForMovement(
      movementType: movementType,
      movementId: movementId,
      container: containerNumber,
    );
  }

  //==========================================================
  //  FACTORY DE PANTALLAS SEGÚN MOVIMIENTO
  //==========================================================
  Widget _buildScreenForMovement({
    required String? movementType,
    required String? movementId,
    required String? container,
  }) {
    if (movementType == null || movementId == null) {
      return _unsupported("Datos insuficientes para iniciar el movimiento");
    }

    switch (movementType) {
      case 'Piso-Camion':
        print('estas en piso camion');
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.pisoCamion,
          tipoMovimientoPantalla: "Piso → Camión",
          movementId: movementId,
        );

      case 'Camion-Piso':
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.camionPiso,
          tipoMovimientoPantalla: "Camión → Piso",
          movementId: movementId,
        );

      case 'Reacomodo':
        return ContainerRearrangementScreen(
          tipoMovimiento: MovementTypes.reacomodo,
          tipoMovimientoPantalla: "Reacomodo",
          movementId: movementId,
        );

      case 'Pesaje':
        return PesajeFormScreen(
          movementId: movementId,
          serie: container,
        );

      default:
        return _unsupported("Tipo de movimiento no soportado: $movementType");
    }
  }

  //==========================================================
  //  WIDGET DE ERROR PARA TIPOS NO DEFINIDOS
  //==========================================================
  Widget _unsupported(String msg) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movimiento no soportado")),
      body: Center(
        child: Text(
          msg,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

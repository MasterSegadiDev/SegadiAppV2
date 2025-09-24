import 'package:flutter/material.dart';
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/services/containers/container_movement_list_service.dart';

class ContainerMovementListViewModel extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  List<ContainerMovement> movimientos = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMovimientos({
    bool forceReload = false,
    required String siteId,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final data = await _service.fetchMovimientos(
        forceReload: forceReload,
        siteId: siteId,
      );

      print("📦 Movimientos recibidos: ${data.length}");

      movimientos = data;
    } catch (e, stackTrace) {
      print('❌ ERROR AL CARGAR LOS MOVIMIENTOS: $e');
      print(stackTrace);
      error = 'No hay movimientos asignados por el momento';
      movimientos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

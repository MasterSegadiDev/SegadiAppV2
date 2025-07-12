import 'package:flutter/material.dart';
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/services/containers/container_movement_list_service.dart';

class ContainerMovementListViewModel extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  List<ContainerMovement> movimientos = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMovimientos({bool forceReload = false}) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _service.fetchMovimientos(forceReload: forceReload);
      movimientos = data;
      error = null;
    } catch (e) {
      error = 'Error al cargar movimientos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

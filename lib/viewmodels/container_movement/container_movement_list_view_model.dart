import 'package:flutter/material.dart';
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/services/containers/container_movement_list_service.dart';

class ContainerMovementListViewModel extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  List<ContainerMovement> _movimientos = [];
  bool _isLoading = false;
  String? _error;

  List<ContainerMovement> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMovimientos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movimientos = await _service.fetchMovimientos();
    } catch (e) {
      print('Error al cargar el listado: ${e}');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

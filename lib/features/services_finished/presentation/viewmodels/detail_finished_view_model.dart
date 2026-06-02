import 'package:flutter/material.dart';
import 'package:segadi/features/services_finished/domain/entities/detail_finished_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/service_finished_repository.dart';

class DetailFinishedViewModel extends ChangeNotifier {
  final ServiceRepository repository;

  DetailFinished? _detail;
  bool _isLoading = false;
  String? _errorMessage;
  bool _canShowCommissions = false;

  DetailFinished? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canShowCommissions => _canShowCommissions;

  DetailFinishedViewModel({required this.repository});

  Future<void> fetchServiceDetail(int serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Obtener preferencia de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // Usamos 'Si' como default por seguridad (si no se sabe, mejor no mostrar datos sensibles)
      final String permiso = prefs.getString('empleado_permisionario') ?? 'Si';

      // Normalizamos a minúsculas para evitar errores de tipado en el string
      _canShowCommissions = (permiso.toLowerCase() == 'no');

      // 2. Llamada al repositorio
      final result = await repository.getServiceDetail(serviceId);

      result.fold(
        (failure) => _errorMessage = failure.message,
        (data) {
          _detail = data;
          // Opcional: Si tu modelo de detalle tiene el campo, lo asignamos
          _detail?.userRoll = _canShowCommissions;
        },
      );
    } catch (e) {
      _errorMessage = "Error inesperado al cargar el detalle";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:segadi/models/services/detail_finished.dart';
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

    // 1. Verificar rol del usuario localmente para seguridad
    final prefs = await SharedPreferences.getInstance();
    final roll = prefs.getString('user_roll') ?? 'No';
    _canShowCommissions = (roll == 'Si');

    // 2. Llamar al repositorio (que usa Either para errores)
    final result = await repository.getServiceDetail(serviceId);

    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) {
        _detail = data;
        _detail?.userRoll = _canShowCommissions;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}

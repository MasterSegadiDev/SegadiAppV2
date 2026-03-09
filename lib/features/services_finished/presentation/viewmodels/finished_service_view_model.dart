import 'package:flutter/material.dart';
import 'package:segadi/features/services_finished/domain/repositories/service_finished_repository.dart';
import 'package:segadi/models/services/services_finished.dart';

class FinishedServicesViewModel extends ChangeNotifier {
  final ServiceRepository repository;

  List<ServicesFinished> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServicesFinished> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FinishedServicesViewModel({required this.repository});

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getFinishedServices();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _services = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}

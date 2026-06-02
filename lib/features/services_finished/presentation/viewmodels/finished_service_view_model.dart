import 'package:flutter/material.dart';
import 'package:segadi/features/services_finished/domain/entities/service_finished.dart';
import 'package:segadi/features/services_finished/domain/repositories/service_finished_repository.dart';

class FinishedServicesViewModel extends ChangeNotifier {
  final ServiceRepository repository;

  List<ServicesFinished> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServicesFinished> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FinishedServicesViewModel({required this.repository});

  String _searchQuery = "";

// Getter para obtener solo los servicios que coinciden con el filtro
  List<ServicesFinished> get filteredServices {
    if (_searchQuery.isEmpty) return services;

    return services.where((s) {
      final query = _searchQuery.toLowerCase();
      // Filtramos por los 3 criterios
      return (s.service.toLowerCase().contains(query)) ||
          (s.client.toLowerCase().contains(query)) ||
          (s.status.toLowerCase().contains(query));
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // Esto redibujará la lista automáticamente
  }

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getFinishedServices();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _services = data,
    );

    print(
        'error al cargar el listado de servicios finalizados: $_errorMessage');

    _isLoading = false;
    notifyListeners();
  }
}

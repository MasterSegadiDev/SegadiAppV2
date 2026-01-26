import 'package:flutter/foundation.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import '../../domain/usecases/get_assigned_services.dart';

class ServicesViewModel extends ChangeNotifier {
  final GetAssignedServices getAssignedServices;

  ServicesState _state = ServicesLoading();
  ServicesState get state => _state;

  ServicesViewModel(this.getAssignedServices);

  Future<void> loadServices() async {
    _state = ServicesLoading();
    notifyListeners();

    try {
      final items = await getAssignedServices();

      if (items.isEmpty) {
        _state = ServicesEmpty();
      } else {
        _state = ServicesLoaded(items);
      }
    } catch (e) {
      _state = ServicesError('Error al cargar servicios');
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadServices();
  }
}

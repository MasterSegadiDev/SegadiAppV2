import 'package:flutter/foundation.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import '../../domain/usecases/get_assigned_services.dart';

class ServicesViewModel extends ChangeNotifier {
  final GetAssignedServices getAssignedServicesUseCase;

  ServicesState _state = ServicesLoading();
  ServicesState get state => _state;

  ServicesViewModel({required this.getAssignedServicesUseCase});

  Future<void> loadServices() async {
    _state = ServicesLoading();
    notifyListeners();

    final result = await getAssignedServicesUseCase();

    result.fold(
      (failure) {
        _state = ServicesError(failure.message);
      },
      (servicesResult) {
        // servicesResult contiene .items y .message
        if (servicesResult.items.isEmpty) {
          // Le pasamos el mensaje que viene del Backend
          _state = ServicesEmpty(servicesResult.message);
        } else {
          _state = ServicesLoaded(servicesResult.items);
        }
      },
    );

    notifyListeners();
  }

  Future<void> refresh() async => await loadServices();
}

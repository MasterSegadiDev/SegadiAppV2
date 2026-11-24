import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/services/domain/entities/assigned_service.dart';

import '../../../domain/usecases/get_assigned_services_usecase.dart';
import '../providers/services_state.dart';

class ServicesViewModel extends StateNotifier<ServicesState> {
  final GetAssignedServicesUseCase _getAssignedServicesUseCase;

  ServicesViewModel(
    this._getAssignedServicesUseCase,
  ) : super(ServicesState.initial());

  Future<void> loadServices() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final result = await _getAssignedServicesUseCase();

    if (result.isSuccess) {
      final services = result.data!;

      state = state.copyWith(
        isLoading: false,
        services: services,
        filteredServices: _filterServices(
          services,
          state.searchQuery,
        ),
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      error: result.failure?.message,
    );
  }

  void searchServices(String query) {
    final filtered = _filterServices(
      state.services,
      query,
    );

    state = state.copyWith(
      searchQuery: query,
      filteredServices: filtered,
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredServices: state.services,
    );
  }

  List<AssignedService> _filterServices(
    List<AssignedService> services,
    String query,
  ) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return services;
    }

    return services.where((service) {
      return service.serviceNumber.toLowerCase().contains(search) ||
          service.origin.toLowerCase().contains(search) ||
          service.destination.toLowerCase().contains(search);
    }).toList();
  }
}

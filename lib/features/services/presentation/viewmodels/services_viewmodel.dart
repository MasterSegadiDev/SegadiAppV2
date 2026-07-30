import 'package:flutter_riverpod/legacy.dart';

import '../../domain/usecases/get_assigned_services_usecase.dart';
import '../providers/services_state.dart';

class ServicesViewModel extends StateNotifier<ServicesState> {
  final GetAssignedServicesUseCase _getAssignedServicesUseCase;

  ServicesViewModel(
    this._getAssignedServicesUseCase,
  ) : super(
          ServicesState.initial(),
        );

  Future<void> loadServices() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final result = await _getAssignedServicesUseCase();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        services: result.data!,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      error: result.failure?.message,
    );
  }
}

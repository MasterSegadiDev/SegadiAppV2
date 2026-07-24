import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/app/di/injection_container.dart';

import '../viewmodels/services_viewmodel.dart';
import '../../domain/usecases/get_assigned_services_usecase.dart';
import 'services_state.dart';

final servicesProvider =
    StateNotifierProvider<ServicesViewModel, ServicesState>(
  (ref) {
    return ServicesViewModel(
      getIt<GetAssignedServicesUseCase>(),
    );
  },
);

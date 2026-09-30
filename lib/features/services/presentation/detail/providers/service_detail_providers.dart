import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_actions_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_info_general_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_service_status_usecase.dart';
import 'package:segadi/features/services/domain/usecases/resolve_evidence_step_usecase.dart';
import 'package:segadi/features/services/domain/usecases/update_mandatory_status_usecase.dart';

import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/detail/state/service_detail_state.dart';
import 'package:segadi/features/services/presentation/detail/viewmodel/service_detail_notifier.dart';

// Puente temporal: los usecases siguen registrados en GetIt (data/domain),
// Riverpod solo los expone para que el notifier no dependa de getIt directamente.
final getServiceGeneralUseCaseProvider =
    Provider<GetServiceGeneralUseCase>((ref) => getIt());

final getServiceActionsUseCaseProvider =
    Provider<GetServiceActionsUseCase>((ref) => getIt());

final getServiceStatusUseCaseProvider =
    Provider<GetServiceStatusUseCase>((ref) => getIt());

final updateMandatoryStatusUseCaseProvider =
    Provider<UpdateMandatoryStatusUseCase>((ref) => getIt());

final resolveEvidenceStepUseCaseProvider =
    Provider<ResolveEvidenceStepUseCase>((ref) => ResolveEvidenceStepUseCase());

final serviceDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<ServiceDetailNotifier, ServiceDetailState, ServiceDetailArguments>(
  (ref, args) {
    final notifier = ServiceDetailNotifier(
      getServiceGeneralUseCase: ref.watch(getServiceGeneralUseCaseProvider),
      getServiceActionsUseCase: ref.watch(getServiceActionsUseCaseProvider),
      getServiceStatusUseCase: ref.watch(getServiceStatusUseCaseProvider),
      updateMandatoryStatusUseCase:
          ref.watch(updateMandatoryStatusUseCaseProvider),
      resolveEvidenceStepUseCase: ref.watch(resolveEvidenceStepUseCaseProvider),
    );

    notifier.initialize(args);
    return notifier;
  },
);

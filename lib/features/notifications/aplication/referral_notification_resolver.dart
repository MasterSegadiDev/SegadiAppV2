import 'package:flutter/foundation.dart';

import 'package:segadi/features/services/domain/usecases/get_assigned_services_usecase.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';

class ReferralNotificationResolver {
  final GetAssignedServicesUseCase _getAssignedServicesUseCase;

  ReferralNotificationResolver(
    this._getAssignedServicesUseCase,
  );

  Future<ServiceDetailArguments?> resolve(
    String serviceNumber,
  ) async {
    debugPrint(
      'FCM: buscando remisión por serviceNumber=$serviceNumber',
    );

    final result = await _getAssignedServicesUseCase();

    if (!result.isSuccess) {
      throw Exception(
        result.failure?.message ?? 'No se pudieron consultar las remisiones.',
      );
    }

    final services = result.data;

    if (services == null) {
      return null;
    }

    for (final service in services) {
      // El backend envía el número de remisión,
      // no el identificador interno.
      if (service.serviceNumber.trim().toUpperCase() ==
          serviceNumber.trim().toUpperCase()) {
        debugPrint(
          'FCM: remisión encontrada: ${service.serviceNumber}',
        );

        return ServiceDetailArguments(
          idSolicitud: service.serviceId,
          idRemision: service.referralId,
          serviceNumber: service.serviceNumber,
        );
      }
    }

    debugPrint(
      'FCM: no se encontró serviceNumber=$serviceNumber',
    );

    return null;
  }
}

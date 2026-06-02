import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/features/service_detail/core/errors/failures.dart';
import 'package:segadi/features/service_detail/data/repositories/airbag_repository_impl.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/domain/utils/airbag_status_mapper.dart';

class ChangeStatusUseCase {
  final DetailServiceRepositoryImpl detailServiceApi;
  final AirbagRepositoryImpl airbagRepository;

  ChangeStatusUseCase(
    this.detailServiceApi,
    this.airbagRepository,
  );

  // Future<Either<Failure, bool>> execute({
  //   required int serviceId,
  //   required int statusId,
  // }) async {
  //   // 1. ERP
  //   final result = await detailServiceApi.changeStatus(
  //     serviceId: serviceId,
  //     statusId: statusId,
  //   );

  //   if (result.isLeft()) {
  //     return result.fold(
  //       (f) => Left(f),
  //       (_) => const Right(false),
  //     );
  //   }

  //   // 2. Airbag
  //   final airbagStatus = mapStatusToAirbag(statusId);

  //   await airbagRepository
  //       .changeOperatorStatus(status: airbagStatus)
  //       .catchError((_) {});

  //   return const Right(true);
  // }

  Future<Either<Failure, bool>> execute({
    required int serviceId,
    required int statusId,
  }) async {
    // 1. Llamada al ERP (Prioridad Alta)
    final result = await detailServiceApi.changeStatus(
      serviceId: serviceId,
      statusId: statusId,
    );

    // 2. Procesamos el resultado del ERP
    return result.fold(
      (failure) => Left(failure), // Error en ERP -> Notificamos a la UI
      (apiResult) async {
        // Verificamos si la respuesta del API fue exitosa (ajusta 'status' según tu modelo)
        final bool isSuccess = apiResult.success == true;

        if (isSuccess) {
          // --- Lógica de Airbag (Solo si el ERP fue exitoso) ---
          final airbagAction = mapStatusToAirbag(statusId);

          if (airbagAction != null) {
            // Solo si es 'active' o 'inactive' llamamos al repositorio
            await airbagRepository.changeOperatorStatus(status: airbagAction);
          } else {
            // Si es null, simplemente ignoramos Airbag y seguimos con el éxito del ERP
            debugPrint(
                'Estatus $statusId no relevante para Airbag. Omitiendo...');
          }

          return const Right(true); // Todo salió bien
        }

        return const Right(false); // El API respondió pero no fue exitoso
      },
    );
  }
}

import 'package:get_it/get_it.dart';

import 'package:segadi/core/device/scanner/scanner_service.dart';

import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource_impl.dart';

import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';
import 'package:segadi/features/evidence/data/repositories/evidence_repository_impl.dart';

import 'package:segadi/features/evidence/domain/usecases/send_delivery_confirmation.dart';
import 'package:segadi/features/evidence/domain/usecases/send_delivery_evidences.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_confirmation_view_model.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_evidence_view_model.dart';

Future<void> setupEvidenceDependencies(GetIt getIt) async {
  getIt.registerLazySingleton<EvidenceRemoteDatasource>(
    () => EvidenceRemoteDatasourceImpl(),
  );

  getIt.registerLazySingleton<EvidenceRepository>(
    () => EvidenceRepositoryImpl(
      remoteDatasource: getIt<EvidenceRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<SendDeliveryConfirmationUseCase>(
    () => SendDeliveryConfirmationUseCase(
      getIt<EvidenceRepository>(),
    ),
  );

  getIt.registerLazySingleton<SendDeliveryEvidencesUseCase>(
    () => SendDeliveryEvidencesUseCase(
      getIt<EvidenceRepository>(),
    ),
  );

  // ViewModel de confirmación
  getIt.registerFactory<DeliveryConfirmationViewModel>(
    () => DeliveryConfirmationViewModel(
      sendDeliveryConfirmation: getIt<SendDeliveryConfirmationUseCase>(),
    ),
  );

  // ViewModel de evidencias
  getIt.registerFactory<DeliveryEvidenceViewModel>(
    () => DeliveryEvidenceViewModel(
      sendDeliveryEvidences: getIt<SendDeliveryEvidencesUseCase>(),
      scannerService: getIt<ScannerService>(),
    ),
  );
}

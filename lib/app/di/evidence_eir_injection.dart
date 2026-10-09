import 'package:get_it/get_it.dart';
import 'package:segadi/core/device/scanner/scanner_service.dart';
import 'package:segadi/features/evidence_eir/data/datasources/evidence_eir_remote_datasource.dart';
import 'package:segadi/features/evidence_eir/data/datasources/evidence_eir_remote_datasource_impl.dart';
import 'package:segadi/features/evidence_eir/data/repositories/evidence_eir_repository_impl.dart';
import 'package:segadi/features/evidence_eir/domain/repositories/evidence_eir_repository.dart';
import 'package:segadi/features/evidence_eir/domain/usecases/send_eir_delivery_evidences_usecase.dart';
import 'package:segadi/features/evidence_eir/presentation/viewmodels/delivery_evidecen_eir_view_model.dart';

Future<void> setupEvidenceEirDependencies(GetIt getIt) async {
  getIt.registerLazySingleton<EvidenceEirRemoteDatasource>(
    () => EvidenceEirRemoteDatasourceImpl(),
  );

  getIt.registerLazySingleton<EvidenceEirRepository>(
    () => EvidenceEirRepositoryImpl(
      remoteDatasource: getIt<EvidenceEirRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<SendEirDeliveryEvidencesUsecase>(
    () => SendEirDeliveryEvidencesUsecase(
      getIt<EvidenceEirRepository>(),
    ),
  );

  // ViewModel de evidencias
  getIt.registerFactory<DeliveryEvidenceEirViewModel>(
    () => DeliveryEvidenceEirViewModel(
      sendEirDeliveryEvidences: getIt<SendEirDeliveryEvidencesUsecase>(),
      scannerService: getIt<ScannerService>(),
    ),
  );
}

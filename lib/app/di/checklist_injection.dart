import 'package:get_it/get_it.dart';
import 'package:segadi/features/check_list/data/datasources/checklist_remote_dataosurce.dart';

import '../../features/check_list/data/repositories/checklist_repository_impl.dart';

import '../../features/check_list/domain/repositories/checklist_repository.dart';
import '../../features/check_list/domain/usecases/get_checklist_usecase.dart';
import '../../features/check_list/domain/usecases/send_checklist_usecase.dart';

import '../../features/check_list/presentation/viewmodels/checklist_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupChecklistDependencies() async {
  /// Datasource
  getIt.registerLazySingleton<ChecklistRemoteDatasource>(
    () => ChecklistRemoteDatasourceImpl(),
  );

  /// Repository
  getIt.registerLazySingleton<ChecklistRepository>(
    () => ChecklistRepositoryImpl(
      remoteDatasource: getIt(),
    ),
  );

  /// UseCases
  getIt.registerLazySingleton(
    () => GetChecklistUseCase(
      getIt(),
    ),
  );

  getIt.registerLazySingleton(
    () => SendChecklistUseCase(
      getIt(),
    ),
  );

  /// ViewModel
  getIt.registerFactory(
    () => ChecklistViewModel(
      getChecklistUseCase: getIt(),
      sendChecklistUseCase: getIt(),
    ),
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injection_container.dart';
import '../../data/models/create_maintenance_request_model.dart';
import '../../domain/usecases/create_maintenance_report_usecase.dart';

final maintenanceReportProvider =
    AsyncNotifierProvider<MaintenanceReportNotifier, MaintenanceReportResult?>(
  MaintenanceReportNotifier.new,
);

class MaintenanceReportNotifier
    extends AsyncNotifier<MaintenanceReportResult?> {
  @override
  Future<MaintenanceReportResult?> build() async {
    return null;
  }

  Future<MaintenanceReportResult> submit(
    CreateMaintenanceRequestModel request, {
    required List<XFile> photos,
  }) async {
    state = const AsyncLoading();

    try {
      final result = await getIt<CreateMaintenanceReportUseCase>().call(
        request,
        photos: photos,
      );

      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

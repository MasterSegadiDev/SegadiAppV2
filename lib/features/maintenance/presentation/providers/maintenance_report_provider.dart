import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_report_detail.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_reports.dart';
import 'package:segadi/features/maintenance/presentation/viewmodels/maintenance_reports_viewmodel.dart';

import '../../../../app/di/injection_container.dart';
import '../../data/models/create_maintenance_request_model.dart';
import '../../domain/entities/maintenance_report.dart';
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

  // Crear un reporte de mantenimiento.
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

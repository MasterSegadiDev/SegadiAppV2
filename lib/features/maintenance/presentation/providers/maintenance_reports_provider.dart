// Consultar los reportes creados por un usuario.
import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/maintenance/domain/entities/maintenance_report.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_report_detail.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_reports.dart';
import 'package:segadi/features/maintenance/presentation/viewmodels/maintenance_reports_viewmodel.dart';

import '../../../../app/di/injection_container.dart';

final maintenanceReportsViewModelProvider =
    StateNotifierProvider<MaintenanceReportsViewModel, MaintenanceReportsState>(
  (ref) {
    return MaintenanceReportsViewModel(
      getReportsUseCase: getIt<GetMaintenanceReports>(),
      getDetailUseCase: getIt<GetMaintenanceReportDetail>(),
      codeCreator: '611',
    );
  },
);

Future<List<MaintenanceReport>> getReports({
  required String codeCreator,
}) async {
  try {
    return await getIt<GetMaintenanceReports>().call(
      codeCreator: codeCreator,
    );
  } catch (error) {
    rethrow;
  }
}

// Consultar el detalle de un reporte.
Future<MaintenanceReport> getReportDetail({
  required int code,
}) async {
  try {
    return await getIt<GetMaintenanceReportDetail>().call(
      code: code,
    );
  } catch (error) {
    rethrow;
  }
}

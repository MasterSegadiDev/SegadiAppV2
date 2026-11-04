import 'package:segadi/features/maintenance/domain/entities/maintenance_report.dart';

abstract class MaintenanceReportsRemoteDatasource {
  Future<List<MaintenanceReport>> getReports({
    required String codeCreator,
  });

  Future<MaintenanceReport> getReportDetail({
    required int code,
  });
}

import '../entities/maintenance_report.dart';

abstract class MaintenanceReportsRepository {
  Future<List<MaintenanceReport>> getReports({
    required String codeCreator,
  });

  Future<MaintenanceReport> getReportDetail({
    required int code,
  });
}

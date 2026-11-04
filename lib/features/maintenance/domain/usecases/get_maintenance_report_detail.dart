import '../entities/maintenance_report.dart';
import '../repositories/maintenance_report_repository.dart';

class GetMaintenanceReportDetail {
  final MaintenanceReportsRepository repository;

  GetMaintenanceReportDetail(this.repository);

  Future<MaintenanceReport> call({
    required int code,
  }) {
    return repository.getReportDetail(
      code: code,
    );
  }
}

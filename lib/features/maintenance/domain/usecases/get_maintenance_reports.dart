import '../entities/maintenance_report.dart';
import '../repositories/maintenance_report_repository.dart';

class GetMaintenanceReports {
  final MaintenanceReportsRepository repository;

  GetMaintenanceReports(this.repository);

  Future<List<MaintenanceReport>> call({
    required String codeCreator,
  }) {
    return repository.getReports(
      codeCreator: codeCreator,
    );
  }
}

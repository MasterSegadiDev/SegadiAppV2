import 'package:segadi/features/maintenance/data/datasources/maintenance_report_remote_datasource.dart';

import '../../domain/entities/maintenance_report.dart';
import '../../domain/repositories/maintenance_report_repository.dart';

class MaintenanceReportRepositoryImpl implements MaintenanceReportRepository {
  final MaintenanceReportsRemoteDatasource remoteDatasource;

  MaintenanceReportRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<List<MaintenanceReport>> getReports({
    required String codeCreator,
  }) {
    return remoteDatasource.getReports(codeCreator: codeCreator);
  }

  @override
  Future<MaintenanceReport> getReportDetail({
    required int code,
  }) {
    return remoteDatasource.getReportDetail(code: code);
  }
}

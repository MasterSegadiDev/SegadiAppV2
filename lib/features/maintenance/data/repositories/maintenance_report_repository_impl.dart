import 'package:segadi/features/maintenance/data/datasources/maintenance_report_remote_datasource.dart';

import '../../domain/entities/maintenance_report.dart';
import '../../domain/repositories/maintenance_report_repository.dart';

class MaintenanceReportRepositoryImpl implements MaintenanceReportsRepository {
  final MaintenanceReportsRemoteDatasource remoteDataSource;

  MaintenanceReportRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<MaintenanceReport>> getReports({
    required String codeCreator,
  }) async {
    return await remoteDataSource.getReports(
      codeCreator: codeCreator,
    );
  }

  @override
  Future<MaintenanceReport> getReportDetail({
    required int code,
  }) async {
    return await remoteDataSource.getReportDetail(
      code: code,
    );
  }
}

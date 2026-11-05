import 'package:segadi/features/maintenance/data/models/maintenance_report_model.dart';

abstract class MaintenanceReportsRemoteDatasource {
  Future<List<MaintenanceReportModel>> getReports({
    required String codeCreator,
  });

  Future<MaintenanceReportModel> getReportDetail({
    required int code,
  });
}

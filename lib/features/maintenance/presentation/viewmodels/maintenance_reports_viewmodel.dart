import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_report_detail.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_maintenance_reports.dart';

import '../../domain/entities/maintenance_report.dart';

class MaintenanceReportsState {
  final bool isLoading;
  final String? error;
  final List<MaintenanceReport> reports;
  final MaintenanceReport? selectedReport;
  final bool isLoadingDetail;

  const MaintenanceReportsState({
    this.isLoading = false,
    this.error,
    this.reports = const [],
    this.selectedReport,
    this.isLoadingDetail = false,
  });

  MaintenanceReportsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<MaintenanceReport>? reports,
    MaintenanceReport? selectedReport,
    bool clearSelectedReport = false,
    bool? isLoadingDetail,
  }) {
    return MaintenanceReportsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      reports: reports ?? this.reports,
      selectedReport:
          clearSelectedReport ? null : selectedReport ?? this.selectedReport,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }
}

class MaintenanceReportsViewModel
    extends StateNotifier<MaintenanceReportsState> {
  final GetMaintenanceReports getReportsUseCase;
  final GetMaintenanceReportDetail getDetailUseCase;
  final String codeCreator;

  MaintenanceReportsViewModel({
    required this.getReportsUseCase,
    required this.getDetailUseCase,
    required this.codeCreator,
  }) : super(const MaintenanceReportsState());

  Future<void> loadReports() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final reports = await getReportsUseCase(
        codeCreator: codeCreator,
      );

      state = state.copyWith(
        isLoading: false,
        reports: reports,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> refreshReports() async {
    await loadReports();
  }

  Future<void> loadReportDetail(int code) async {
    state = state.copyWith(
      isLoadingDetail: true,
      clearError: true,
      clearSelectedReport: true,
    );

    try {
      final report = await getDetailUseCase(code: code);

      state = state.copyWith(
        isLoadingDetail: false,
        selectedReport: report,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingDetail: false,
        error: error.toString(),
      );
    }
  }

  void clearSelectedReport() {
    state = state.copyWith(
      clearSelectedReport: true,
      clearError: true,
    );
  }
}

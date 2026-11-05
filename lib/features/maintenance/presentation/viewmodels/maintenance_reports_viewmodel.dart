import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/maintenance_report.dart';
import '../../domain/usecases/get_maintenance_report_detail.dart';
import '../../domain/usecases/get_maintenance_reports.dart';

class MaintenanceReportsState {
  final bool isLoading;
  final bool isLoadingDetail;
  final String? error;
  final List<MaintenanceReport> reports;
  final MaintenanceReport? selectedReport;

  const MaintenanceReportsState({
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.error,
    this.reports = const [],
    this.selectedReport,
  });

  MaintenanceReportsState copyWith({
    bool? isLoading,
    bool? isLoadingDetail,
    String? error,
    List<MaintenanceReport>? reports,
    MaintenanceReport? selectedReport,
    bool clearError = false,
    bool clearSelectedReport = false,
  }) {
    return MaintenanceReportsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      error: clearError ? null : (error ?? this.error),
      reports: reports ?? this.reports,
      selectedReport:
          clearSelectedReport ? null : (selectedReport ?? this.selectedReport),
    );
  }

  // Estados que se muestran en la pestaña En proceso.
  List<MaintenanceReport> get reportsInProgress {
    const statuses = [1, 2, 3, 7, 8, 10, 11, 13];

    return reports
        .where((report) => statuses.contains(report.idStatus))
        .toList();
  }

  // Estados que se muestran en la pestaña Resueltos.
  List<MaintenanceReport> get resolvedReports {
    return reports
        .where((report) => report.idStatus == 4 || report.idStatus == 6)
        .toList();
  }
}

class MaintenanceReportsViewModel
    extends StateNotifier<MaintenanceReportsState> {
  final GetMaintenanceReports getReportsUseCase;
  final GetMaintenanceReportDetail getDetailUseCase;
  final String codeCreator;

  Timer? _pollingTimer;
  bool _isFetching = false;

  MaintenanceReportsViewModel({
    required this.getReportsUseCase,
    required this.getDetailUseCase,
    required this.codeCreator,
  }) : super(const MaintenanceReportsState());

  /// Consulta inicial de solicitudes.
  Future<void> loadReports() async {
    await _fetchReports(showLoading: true);
  }

  /// Actualiza la lista sin mostrar la pantalla de carga completa.
  Future<void> refreshReports() async {
    await _fetchReports();
  }

  Future<void> _fetchReports({bool showLoading = false}) async {
    if (_isFetching) return;

    _isFetching = true;

    if (showLoading) {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );
    }

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
    } finally {
      _isFetching = false;
    }
  }

  /// Consulta el detalle de una solicitud.
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
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingDetail: false,
        error: error.toString(),
      );
    }
  }

  /// Inicia la actualización automática cada 45 segundos.
  void startPolling() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) {
        refreshReports();
      },
    );
  }

  /// Detiene la actualización automática.
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void clearSelectedReport() {
    state = state.copyWith(
      clearSelectedReport: true,
      clearError: true,
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

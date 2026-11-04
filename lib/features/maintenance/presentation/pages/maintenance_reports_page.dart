import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/maintenance/presentation/providers/maintenance_report_provider.dart';
import 'package:segadi/features/maintenance/presentation/viewmodels/maintenance_reports_viewmodel.dart';

import '../../domain/entities/maintenance_report.dart';

class MaintenanceReportsPage extends ConsumerStatefulWidget {
  const MaintenanceReportsPage({
    super.key,
    required this.onReportTap,
    this.onNewReport,
  });

  final ValueChanged<MaintenanceReport> onReportTap;
  final VoidCallback? onNewReport;

  @override
  ConsumerState<MaintenanceReportsPage> createState() =>
      _MaintenanceReportsPageState();
}

class _MaintenanceReportsPageState
    extends ConsumerState<MaintenanceReportsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(maintenanceReportProvider.notifier)
          .getReports(codeCreator: '611');
    });
  }

  Future<void> refresh() async {
    await ref
        .read(maintenanceReportProvider.notifier)
        .getReports(codeCreator: '611');
  }

  Color statusColor(String status) {
    final s = status.toLowerCase();

    if (s.contains('cerrad') || s.contains('complet')) {
      return const Color(0xFF23834A);
    }

    if (s.contains('rechaz') || s.contains('cancel')) {
      return Colors.red.shade700;
    }

    if (s.contains('proceso') || s.contains('atend')) {
      return Colors.orange.shade800;
    }

    return Colors.blueGrey;
  }

  String dateText(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        title: const Text('Mis reportes de mantenimiento'),
        backgroundColor: const Color(0xFF101812),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: widget.onNewReport == null
          ? null
          : FloatingActionButton.extended(
              onPressed: widget.onNewReport,
              backgroundColor: const Color(0xFF1E7A3C),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo reporte'),
            ),
      body: _buildBody(state as MaintenanceReportsState),
    );
  }

  Widget _buildBody(MaintenanceReportsState state) {
    if (state.isLoading && state.reports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('No fue posible cargar tus reportes.'),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: refresh,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 130),
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Aún no tienes reportes de mantenimiento.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: state.reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final report = state.reports[i];

          return Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => widget.onReportTap(report),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.idCode as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(report.statusColor ?? '')
                                .withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            report.statusDescription ?? '',
                            style: TextStyle(
                              color: statusColor(report.statusNotes ?? ''),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      report.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            report.identifier ?? '',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateText(report.date as DateTime),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Ver detalle  ›',
                        style: TextStyle(
                          color: Color(0xFF1E7A3C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

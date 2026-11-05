import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/maintenance/presentation/pages/maintenance_report_detail_page.dart';
import 'package:segadi/features/maintenance/presentation/viewmodels/maintenance_reports_viewmodel.dart';

import '../../domain/entities/maintenance_report.dart';
import '../providers/maintenance_reports_provider.dart';
//import 'maintenance_report_detail_page.dart';

const Color _darkGreen = Color(0xFF10372D);
const Color _primaryGreen = Color(0xFF147A4B);
const Color _background = Color(0xFFF5F7F5);

class MaintenanceReportsPage extends ConsumerStatefulWidget {
  const MaintenanceReportsPage({super.key});

  @override
  ConsumerState<MaintenanceReportsPage> createState() =>
      _MaintenanceReportsPageState();
}

class _MaintenanceReportsPageState
    extends ConsumerState<MaintenanceReportsPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(maintenanceReportsViewModelProvider.notifier).loadReports();
    });
  }

  bool _isResolved(MaintenanceReport report) {
    return report.idStatus == 4 || report.idStatus == 6;
  }

  bool _isOtherClosed(MaintenanceReport report) {
    return report.idStatus == 5 ||
        report.idStatus == 9 ||
        report.idStatus == 12;
  }

  List<MaintenanceReport> _getReports(
    List<MaintenanceReport> reports,
  ) {
    if (_selectedTab == 0) {
      return reports
          .where((report) => !_isResolved(report) && !_isOtherClosed(report))
          .toList();
    }

    // La pestaña Resueltos muestra únicamente solicitudes resueltas.
    return reports.where(_isResolved).toList();
  }

  String _statusLabel(MaintenanceReport report) {
    switch (report.idStatus) {
      case 1:
        return 'Abierto';
      case 2:
        return 'En proceso';
      case 3:
        return 'OT en proceso';
      case 4:
        return 'Resuelto sin OT';
      case 5:
        return 'Cancelado';
      case 6:
        return 'Resuelto con OT';
      case 7:
        return 'Esperando una OT';
      case 8:
        return 'OT en revisión';
      case 9:
        return 'OT cancelada';
      case 10:
        return 'Esperando otra OT';
      case 11:
        return 'Retirada de tareas pendientes';
      case 12:
        return 'Rechazado';
      case 13:
        return 'Portal de invitados';
      default:
        return report.statusDescription?.isNotEmpty == true
            ? report.statusDescription!
            : 'Estado no disponible';
    }
  }

  Color _statusColor(MaintenanceReport report) {
    switch (report.idStatus) {
      case 1:
        return const Color(0xFFD18A16);
      case 2:
      case 3:
      case 7:
      case 10:
        return const Color(0xFF1765B5);
      case 4:
      case 6:
        return const Color(0xFF16834A);
      case 5:
      case 9:
      case 11:
      case 12:
        return const Color(0xFFB42318);
      case 8:
        return const Color(0xFF7041A6);
      case 13:
        return const Color(0xFF64748B);
      default:
        return Colors.blueGrey;
    }
  }

  String _dateText(String? value) {
    if (value == null || value.isEmpty) return 'Sin fecha';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');

    return '$day ${_monthName(local.month)} ${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return months[month - 1];
  }

  Future<void> _openDetail(MaintenanceReport report) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaintenanceReportDetailPage(
          code: report.idCode,
        ),
      ),
    );

    if (!mounted) return;

    ref.read(maintenanceReportsViewModelProvider.notifier).refreshReports();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceReportsViewModelProvider);

    final inProgress = state.reportsInProgress;
    final resolved = state.resolvedReports;

    final reports = _selectedTab == 0 ? inProgress : resolved;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis reportes de mantenimiento',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _tabButton(
                  title: 'En proceso',
                  count: inProgress.length,
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _tabButton(
                  title: 'Resueltos',
                  count: resolved.length,
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(
              state: state,
              reports: reports,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '$title ($count)',
                style: TextStyle(
                  color: selected ? _primaryGreen : Colors.black54,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? _primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required MaintenanceReportsState state,
    required List<MaintenanceReport> reports,
  }) {
    if (state.isLoading && state.reports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryGreen),
      );
    }

    if (state.error != null && state.reports.isEmpty) {
      return _errorView(state.error!);
    }

    if (reports.isEmpty) {
      return RefreshIndicator(
        color: _primaryGreen,
        onRefresh: () => ref
            .read(maintenanceReportsViewModelProvider.notifier)
            .refreshReports(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 110),
            Icon(
              Icons.assignment_outlined,
              size: 58,
              color: Colors.black26,
            ),
            SizedBox(height: 14),
            Center(
              child: Text(
                'No hay reportes en esta sección.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: () => ref
          .read(maintenanceReportsViewModelProvider.notifier)
          .refreshReports(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final report = reports[index];

          return _ReportCard(
            report: report,
            statusLabel: _statusLabel(report),
            statusColor: _statusColor(report),
            dateText: _dateText(
              report.dateIncident ?? report.date,
            ),
            onTap: () => _openDetail(report),
          );
        },
      ),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No fue posible cargar tus reportes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref
                  .read(maintenanceReportsViewModelProvider.notifier)
                  .loadReports(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.statusLabel,
    required this.statusColor,
    required this.dateText,
    required this.onTap,
  });

  final MaintenanceReport report;
  final String statusLabel;
  final Color statusColor;
  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unit = report.codeItem?.isNotEmpty == true
        ? report.codeItem!
        : report.itemDescription ?? 'Unidad no especificada';

    final folio = 'WR-${report.idCode}';
    final description = report.description?.trim().isNotEmpty == true
        ? report.description!.trim()
        : 'Sin descripción';

    final observation = report.observation?.trim() ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7EAE7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: _darkGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF17231A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          folio,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black87,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (observation.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  observation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

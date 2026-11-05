import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/maintenance/presentation/viewmodels/maintenance_reports_viewmodel.dart';

import '../../domain/entities/maintenance_report.dart';
import '../providers/maintenance_reports_provider.dart';

const Color _detailDarkGreen = Color(0xFF10372D);
const Color _detailGreen = Color(0xFF147A4B);
const Color _detailBackground = Color(0xFFF5F7F5);

class MaintenanceReportDetailPage extends ConsumerStatefulWidget {
  const MaintenanceReportDetailPage({
    super.key,
    required this.code,
  });

  final int code;

  @override
  ConsumerState<MaintenanceReportDetailPage> createState() =>
      _MaintenanceReportDetailPageState();
}

class _MaintenanceReportDetailPageState
    extends ConsumerState<MaintenanceReportDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref
          .read(maintenanceReportsViewModelProvider.notifier)
          .loadReportDetail(widget.code);
    });
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
      default:
        return Colors.blueGrey;
    }
  }

  String _dateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'No disponible';
    }

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceReportsViewModelProvider);

    return Scaffold(
      backgroundColor: _detailBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle del reporte',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(MaintenanceReportsState state) {
    if (state.isLoadingDetail && state.selectedReport == null) {
      return const Center(
        child: CircularProgressIndicator(color: _detailGreen),
      );
    }

    if (state.error != null && state.selectedReport == null) {
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
                'No fue posible consultar el detalle.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
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
                    .loadReportDetail(widget.code),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final report = state.selectedReport;

    if (report == null) {
      return const Center(
        child: Text('No se encontró información del reporte.'),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            _buildHeader(report),
            const SizedBox(height: 14),
            _buildDescription(report),
            const SizedBox(height: 14),
            _buildObservations(report),
            const SizedBox(height: 14),
            _buildClassification(report),
            const SizedBox(height: 14),
            _buildAdditionalInformation(report),
            const SizedBox(height: 14),
            _buildAnnotations(report),
          ],
        ),
        if (state.isLoadingDetail)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              color: _detailGreen,
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(MaintenanceReport report) {
    final color = _statusColor(report);

    final unit = report.codeItem?.isNotEmpty == true
        ? report.codeItem!
        : report.itemDescription ?? 'Unidad no especificada';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(report),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.access_time,
                size: 14,
                color: Colors.black45,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  _dateText(report.dateIncident ?? report.date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: _detailDarkGreen,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'WR-${report.idCode}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(MaintenanceReport report) {
    return _Panel(
      title: 'Descripción',
      child: Text(
        report.description?.isNotEmpty == true
            ? report.description!
            : 'Sin descripción registrada.',
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Color(0xFF343B36),
        ),
      ),
    );
  }

  Widget _buildObservations(MaintenanceReport report) {
    return _Panel(
      title: 'Observaciones',
      child: Text(
        report.observation?.isNotEmpty == true
            ? report.observation!
            : 'Sin observaciones registradas.',
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Color(0xFF343B36),
        ),
      ),
    );
  }

  Widget _buildClassification(MaintenanceReport report) {
    return _Panel(
      title: 'Clasificación',
      child: Column(
        children: [
          _InfoRow(
            label: 'Grupo',
            value: report.typeDescription,
          ),
          _InfoRow(
            label: 'Clasificación 1',
            value: report.type1Description,
          ),
          _InfoRow(
            label: 'Clasificación 2',
            value: report.type2Description,
          ),
          _InfoRow(
            label: 'Prioridad',
            value: report.priorityDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInformation(MaintenanceReport report) {
    return _Panel(
      title: 'Información adicional',
      child: Column(
        children: [
          _InfoRow(
            label: 'Fecha del incidente',
            value: _dateText(report.dateIncident),
          ),
          _InfoRow(
            label: 'Solicitado por',
            value: report.requestedBy,
          ),
          _InfoRow(
            label: 'Estatus actual',
            value: _statusLabel(report),
          ),
          _InfoRow(
            label: 'Orden de trabajo',
            value: report.workOrderFolio?.toString(),
          ),
          _InfoRow(
            label: 'Centro de costos',
            value: report.costCenterDescription,
          ),
          _InfoRow(
            label: 'Cuenta',
            value: report.accountsName,
          ),
          _InfoRow(
            label: 'Correo',
            value: report.accountsEmail,
          ),
          _InfoRow(
            label: 'Fecha de solución',
            value: _dateText(report.dateSolution),
          ),
          _InfoRow(
            label: '¿Es urgente?',
            value: report.isUrgent == true ? 'Sí' : 'No',
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotations(MaintenanceReport report) {
    final notes = report.statusNotes?.trim() ?? '';
    final annotations = report.annotations?.trim() ?? '';

    if (notes.isEmpty && annotations.isEmpty) {
      return const SizedBox.shrink();
    }

    return _Panel(
      title: 'Seguimiento del reporte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notes.isNotEmpty) ...[
            const Text(
              'Notas del estatus',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(notes),
          ],
          if (notes.isNotEmpty && annotations.isNotEmpty)
            const SizedBox(height: 12),
          if (annotations.isNotEmpty) ...[
            const Text(
              'Anotaciones',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(annotations),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.title,
  });

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Color(0xFF17231A),
              ),
            ),
            const SizedBox(height: 13),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF26332B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

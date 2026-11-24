import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

import 'package:segadi/features/services/domain/enums/evidence_step.dart';
import 'package:segadi/features/services/domain/enums/service_action.dart';

import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/detail/providers/service_detail_providers.dart';
import 'package:segadi/features/services/presentation/detail/state/service_detail_state.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/pending_evidence_banner.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/recipient_card.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/sender_card.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/service_actions_card.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/service_header_card.dart';
import 'package:segadi/features/services/presentation/detail/widgets/detail/service_status_button.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';
import 'package:segadi/features/support_status/presentation/widgets/support_status_modal.dart';

class _C {
  static const background = Color(0xFFF7F8F6);
  static const surfaceDark = Color(0xFF101812);

  static const primaryGreen = Color(0xFF1E7A3C);
  static const primaryGreenSoft = Color(0xFFE1F0E3);

  static const textPrimary = Color(0xFF101812);
  static const textSecondary = Color(0xFF6B6B66);
}

class ServiceDetailPage extends ConsumerStatefulWidget {
  final ServiceDetailArguments arguments;

  const ServiceDetailPage({
    super.key,
    required this.arguments,
  });

  @override
  ConsumerState<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends ConsumerState<ServiceDetailPage> {
  bool _navigatingToEvidence = false;
  bool _isFinishingSupport = false;

  bool _shouldShowEvidenceBanner(ServiceDetailState state) {
    return state.canOpenEvidence &&
        (state.evidenceStep == EvidenceStep.confirmationPending ||
            state.evidenceStep == EvidenceStep.evidencePending);
  }

  Future<void> _finishSupport(
    SupportStatusCurrentEntity supportStatus,
  ) async {
    if (_isFinishingSupport) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar soporte'),
          content: Text(
            '¿Deseas finalizar el soporte "${supportStatus.statusName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9382E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isFinishingSupport = true);

    final supportViewModel = getIt<SupportStatusViewModel>();

    try {
      final success = await supportViewModel.sendStatusById(
        referralId: widget.arguments.idRemision,
        serviceRequestId: widget.arguments.idSolicitud,
        statusId: supportStatus.id,
      );

      if (!mounted) return;

      if (success) {
        await ref
            .read(serviceDetailNotifierProvider(widget.arguments).notifier)
            .refreshAfterSupport();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soporte finalizado correctamente.'),
            backgroundColor: Color(0xFF1E7A3C),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              supportViewModel.error ?? 'No se pudo finalizar el soporte.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      supportViewModel.dispose();

      if (mounted) {
        setState(() => _isFinishingSupport = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceDetailNotifierProvider(widget.arguments));

    ref.listen<ServiceDetailState>(
      serviceDetailNotifierProvider(widget.arguments),
      (previous, next) {
        if (previous == null) return;

        final registeredDownloadEnd = previous
                    .serviceStatus?.nextMandatoryStatus ==
                'Término de descarga' &&
            next.serviceStatus?.nextMandatoryStatus == 'Salida de destinatario';

        if (registeredDownloadEnd && next.hasPendingEvidence) {
          _handleEvidenceStep(next.evidenceStep);
        }
      },
    );

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: Center(child: Text(state.error!)),
      );
    }

    final notifier =
        ref.read(serviceDetailNotifierProvider(widget.arguments).notifier);

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detalle del servicio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_shouldShowEvidenceBanner(state))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: PendingEvidenceBanner(
                  onContinue: () => _handleEvidenceStep(state.evidenceStep),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                color: _C.primaryGreen,
                onRefresh: notifier.refreshServiceState,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Servicio asignado',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _C.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ServiceHeaderCard(
                        serviceNumber: state.serviceNumber,
                      ),
                      const SizedBox(height: 26),
                      const _SectionTitle(
                        icon: Icons.people_outline,
                        title: 'Información del servicio',
                      ),
                      const SizedBox(height: 10),
                      SenderCard(
                        name: state.service?.sender.name ?? '',
                        phone: state.service?.sender.phone ?? '',
                        directContact:
                            state.service?.sender.directContact ?? '',
                        address: state.service?.sender.address ?? '',
                      ),
                      const SizedBox(height: 12),
                      RecipientCard(
                        name: state.service?.recipient.name ?? '',
                        phone: state.service?.recipient.phone ?? '',
                        directContact:
                            state.service?.recipient.directContact ?? '',
                        address: state.service?.recipient.address ?? '',
                      ),
                      const SizedBox(height: 26),
                      ServiceActionsCard(
                        actions: notifier.actionItems,
                        supportStatus: state.currentSupportStatus,
                        onActionTap: (item) => _onActionTap(item.key, notifier),
                        onFinishSupport: (supportStatus) async {
                          final supportViewModel =
                              getIt<SupportStatusViewModel>();

                          final success = await supportViewModel.sendStatusById(
                            referralId: widget.arguments.idRemision,
                            serviceRequestId: widget.arguments.idSolicitud,
                            statusId: supportStatus.id,
                          );

                          if (success) {
                            await notifier.refreshAfterSupport();
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    supportViewModel.error ??
                                        'No se pudo finalizar el soporte.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }

                          return success;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildStatusButtonBar(
              context,
              state,
              notifier,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onActionTap(ServiceAction action, notifier) async {
    switch (action) {
      case ServiceAction.checklist:
        final result = await context.push<bool>(
          '/checklist',
          extra: ChecklistArguments(
            referralId: widget.arguments.idSolicitud,
            serviceNumber: widget.arguments.serviceNumber,
          ),
        );

        if (result == true) {
          await notifier.refreshServiceState();
        }
        break;

      case ServiceAction.support:
        final success = await _openSupportStatusModal(
          idRemision: widget.arguments.idRemision,
          idSolicitud: widget.arguments.idSolicitud,
        );

        if (success == true) {
          await notifier.refreshAfterSupport();
        }
        break;

      case ServiceAction.route:
        context.push('/georoute', extra: widget.arguments.idSolicitud);
        break;

      case ServiceAction.closeEvidence:
        context.push('/evidence/eir', extra: widget.arguments);
        break;

      case ServiceAction.travelExpenses:
        context.push('/travel-expenses', extra: widget.arguments);
      case ServiceAction.downloadCcp:
        break;
    }
  }

  Future<void> _handleEvidenceStep(EvidenceStep step) async {
    if (!mounted || _navigatingToEvidence) return;

    if (step != EvidenceStep.confirmationPending &&
        step != EvidenceStep.evidencePending) {
      return;
    }

    _navigatingToEvidence = true;

    try {
      if (step == EvidenceStep.confirmationPending) {
        await _pushEvidenceRoute('/evidence/confirmation');
      } else {
        await _pushEvidenceRoute('/evidence/capture');
      }
    } finally {
      _navigatingToEvidence = false;
    }
  }

  Future<void> _pushEvidenceRoute(String route) async {
    await context.push(
      route,
      extra: widget.arguments,
    );

    if (!mounted) return;

    await ref
        .read(serviceDetailNotifierProvider(widget.arguments).notifier)
        .refreshServiceState();
  }

  Future<bool?> _openSupportStatusModal({
    required String idRemision,
    required String idSolicitud,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider(
          create: (_) => getIt<SupportStatusViewModel>(),
          child: SupportStatusModal(
            idRemision: idRemision,
            idSolicitud: idSolicitud,
          ),
        );
      },
    );
  }

  Widget _buildStatusButtonBar(
    BuildContext context,
    ServiceDetailState state,
    notifier,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ServiceStatusButton(
        status: state.statusName,
        enabled: state.canUpdateStatus,
        onPressed: () async {
          final success = await notifier.updateMandatoryStatus();

          if (!context.mounted || !success) return;

          // Actualizar servicio, estatus y estado de evidencias.
          await notifier.refreshServiceState();

          if (!context.mounted) return;

          // Leer el estado actualizado.
          final updatedState = ref.read(
            serviceDetailNotifierProvider(widget.arguments),
          );

          if (updatedState.hasPendingEvidence) {
            // No mostrar mensaje de estatus normal.
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estatus actualizado correctamente.'),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.primaryGreenSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: _C.primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

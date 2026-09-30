import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';

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
import 'package:segadi/features/services/presentation/list/arguments/service_action_item.dart';

import 'package:segadi/features/support_status/presentation/widgets/support_status_modal.dart';

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

  bool _shouldShowEvidenceBanner(EvidenceStep step) {
    return step == EvidenceStep.confirmationPending ||
        step == EvidenceStep.evidencePending;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceDetailNotifierProvider(widget.arguments));

    ref.listen<ServiceDetailState>(
      serviceDetailNotifierProvider(widget.arguments),
      (previous, next) {
        if (previous?.evidenceStep != next.evidenceStep) {
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
      appBar: AppBar(title: const Text('Detalle del Servicio')),
      body: SafeArea(
        child: Column(
          children: [
            if (_shouldShowEvidenceBanner(state.evidenceStep))
              PendingEvidenceBanner(
                onContinue: () => _handleEvidenceStep(state.evidenceStep),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ServiceHeaderCard(serviceNumber: state.serviceNumber),
                    const SizedBox(height: 16),
                    SenderCard(
                      name: state.service?.sender?.name ?? '',
                      phone: state.service?.sender?.phone ?? '',
                      directContact: state.service?.sender?.directContact ?? '',
                      address: state.service?.sender?.address ?? '',
                    ),
                    RecipientCard(
                      name: state.service?.recipient?.name ?? '',
                      phone: state.service?.recipient?.phone ?? '',
                      directContact:
                          state.service?.recipient?.directContact ?? '',
                      address: state.service?.recipient?.address ?? '',
                    ),
                    ServiceActionsCard(
                      actions: notifier.actionItems,
                      supportStatus: state.currentSupportStatus,
                      onActionTap: (ServiceActionItem item) =>
                          _onActionTap(item.key, notifier),
                    ),
                  ],
                ),
              ),
            ),
            _buildStatusButtonBar(context, state, notifier),
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
        _handleEvidenceStep(
          ref
              .read(serviceDetailNotifierProvider(widget.arguments))
              .evidenceStep,
        );
        break;

      case ServiceAction.travelExpenses:
      case ServiceAction.downloadCcp:
        break;
    }
  }

  Future<void> _handleEvidenceStep(EvidenceStep step) async {
    if (!mounted || _navigatingToEvidence) return;

    switch (step) {
      case EvidenceStep.confirmationPending:
        await _pushEvidenceRoute('/evidence/confirmation');
        break;
      case EvidenceStep.evidencePending:
        await _pushEvidenceRoute('/evidence/capture');
        break;
      case EvidenceStep.completed:
      case EvidenceStep.notApplicable:
        break;
    }
  }

  Future<void> _pushEvidenceRoute(String route) async {
    _navigatingToEvidence = true;

    final result = await context.push<bool>(route, extra: widget.arguments);

    if (!mounted) return;

    _navigatingToEvidence = false;

    if (result == true) {
      ref
          .read(serviceDetailNotifierProvider(widget.arguments).notifier)
          .refreshServiceState();
    }
  }

  Future<bool?> _openSupportStatusModal({
    required String idRemision,
    required String idSolicitud,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => SupportStatusModal(
        idRemision: idRemision,
        idSolicitud: idSolicitud,
      ),
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
          if (!context.mounted) return;
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Estatus actualizado correctamente.'),
              ),
            );
          }
        },
      ),
    );
  }
}

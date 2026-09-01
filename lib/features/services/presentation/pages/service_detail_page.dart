import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';
import 'package:segadi/features/check_list/presentation/pages/checklist_page.dart';
import 'package:segadi/features/georuta/presentation/pages/georoute_page.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/recipient_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/sender_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_actions_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_header_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_status_button.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';
import 'package:segadi/features/support_status/presentation/widgets/support_status_modal.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceDetailArguments arguments;

  const ServiceDetailPage({
    super.key,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ServiceDetailViewModel>(
      create: (_) => getIt<ServiceDetailViewModel>(),
      child: _ServiceDetailView(arguments: arguments),
    );
  }
}

class _ServiceDetailView extends StatefulWidget {
  final ServiceDetailArguments arguments;

  const _ServiceDetailView({
    required this.arguments,
  });

  @override
  State<_ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<_ServiceDetailView> {
  late final ServiceDetailViewModel _vm;

  bool _initialized = false;
  bool _navigatingToEvidence = false;

  @override
  void initState() {
    super.initState();

    _vm = context.read<ServiceDetailViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!mounted || _initialized) {
      return;
    }

    _initialized = true;

    await _vm.initialize(
      widget.arguments,
    );

    if (!mounted) {
      return;
    }

    await _checkEvidenceFlow();
  }

  Future<void> _checkEvidenceFlow() async {
    if (!mounted || _navigatingToEvidence) {
      return;
    }

    final service = _vm.service;

    if (service == null) {
      return;
    }

    if (!service.blnConfirmation) {
      await _openConfirmation();
      return;
    }

    if (!service.blnEvidence) {
      await _openCapture();
      return;
    }
  }

  Future<void> _openConfirmation() async {
    if (!mounted || _navigatingToEvidence) {
      return;
    }

    _navigatingToEvidence = true;

    final result = await context.push<bool>(
      '/evidence/confirmation',
      extra: widget.arguments,
    );

    if (!mounted) {
      return;
    }

    _navigatingToEvidence = false;

    if (result == true) {
      await _vm.refreshServiceState();

      if (!mounted) {
        return;
      }

      await _checkEvidenceFlow();
    }
  }

  Future<void> _openCapture() async {
    if (!mounted || _navigatingToEvidence) {
      return;
    }

    _navigatingToEvidence = true;

    final result = await context.push<bool>(
      '/evidence/capture',
      extra: widget.arguments,
    );

    if (!mounted) {
      return;
    }

    _navigatingToEvidence = false;

    if (result == true) {
      await _vm.refreshServiceState();

      if (!mounted) {
        return;
      }

      await _checkEvidenceFlow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceDetailViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vm.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle'),
        ),
        body: Center(
          child: Text(vm.error!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Servicio',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ServiceHeaderCard(
              serviceNumber: vm.arguments?.serviceNumber ?? '',
            ),
            const SizedBox(height: 16),
            SenderCard(
              name: '',
              phone: '',
              directContact: '',
              address: '',
            ),
            RecipientCard(
              name: '',
              phone: '',
              directContact: '',
              address: '',
            ),
            ServiceActionsCard(
              actions: vm.actionItems,
              supportStatus: vm.currentSupportStatus,
              onActionTap: (action) async {
                switch (action.key) {
                  case 'checklist':
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChecklistPage(
                          arguments: ChecklistArguments(
                            referralId: vm.arguments?.idRemision ?? '',
                            serviceNumber: vm.arguments?.serviceNumber ?? '',
                          ),
                        ),
                      ),
                    );

                    if (result == true) {
                      await vm.refreshServiceState();
                    }

                    break;

                  case 'support':
                    final success = await openSupportStatusModal(
                      context,
                      idRemision: vm.arguments?.idRemision ?? '',
                      idSolicitud: vm.arguments?.idSolicitud ?? '',
                    );

                    if (success == true) {
                      await vm.refreshAfterSupport();
                    }

                    break;

                  case 'route':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GeoroutePage(
                          serviceRequestId: vm.arguments?.idSolicitud ?? '',
                        ),
                      ),
                    );

                    break;

                  case 'close_evidence':
                    await _checkEvidenceFlow();
                    break;

                  case 'travel_expenses':
                    break;

                  case 'download_ccp':
                    break;
                }
              },
            ),
            ServiceStatusButton(
              status: vm.nextStatusName,
              enabled: vm.enableStatusButton,
              onPressed: () async {
                final success = await vm.updateMandatoryStatus();

                if (!context.mounted) {
                  return;
                }

                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Estatus actualizado correctamente.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> openSupportStatusModal(
    BuildContext context, {
    required String idRemision,
    required String idSolicitud,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return ChangeNotifierProvider(
          create: (_) => getIt<SupportStatusViewModel>()..loadStatuses(),
          child: SupportStatusModal(
            idRemision: idRemision,
            idSolicitud: idSolicitud,
          ),
        );
      },
    );
  }
}

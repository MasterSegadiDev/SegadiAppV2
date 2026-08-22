import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';
import 'package:segadi/features/check_list/presentation/pages/checklist_page.dart';
import 'package:segadi/features/georuta/presentation/pages/georoute_page.dart';

import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/recipient_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/sender_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_actions_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_header_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_status_button.dart';

import 'package:segadi/features/support_status/presentation/widgets/support_status_modal.dart';
import 'package:segadi/features/support_status/domain/entities/support_status_entity.dart';

import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

import '../../../../app/di/injection_container.dart';
import '../viewmodels/service_detail_viewmodel.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceDetailArguments arguments;

  const ServiceDetailPage({
    super.key,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ServiceDetailViewModel>()..initialize(arguments),
      child: const _ServiceDetailView(),
    );
  }
}

class _ServiceDetailView extends StatelessWidget {
  const _ServiceDetailView();

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
          title: const Text(
            'Detalle',
          ),
        ),
        body: Center(
          child: Text(
            vm.error!,
          ),
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
              serviceNumber: vm.arguments.serviceNumber,
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
                            referralId: vm.arguments.idRemision,
                            serviceNumber: vm.arguments.serviceNumber,
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
                      idRemision: vm.arguments.idRemision,
                      idSolicitud: vm.arguments.idSolicitud,
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
                          serviceRequestId: vm.arguments.idSolicitud,
                        ),
                      ),
                    );

                    break;

                  case 'close_evidence':
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
                  ScaffoldMessenger.of(context).showSnackBar(
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

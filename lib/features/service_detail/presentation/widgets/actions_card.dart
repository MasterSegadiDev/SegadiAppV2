import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/check_list/data/datasources/checklist_api.dart';
import 'package:segadi/features/check_list/data/repositories/checklist_repository_impl.dart';
import 'package:segadi/features/check_list/presentation/pages/checklist_page.dart';
import 'package:segadi/features/check_list/presentation/viewmodels/checklist_viewmodel.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/support_status/data/api/support_status_api.dart';
import 'package:segadi/features/support_status/data/repositories/support_status_repository_impl.dart';
import 'package:segadi/features/support_status/presentation/ui/status_support_view.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';
import 'package:segadi/features/trip_closure/presentation/pages/capture_trip_evidence_page.dart';
import 'package:segadi/views/services/detail_service.dart';

class ActionsCard extends StatelessWidget {
  final DetailServiceEntity ui;
  final VoidCallback onRefresh;

  const ActionsCard({
    super.key,
    required this.ui,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final e = ui;
    final state = ui;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─────────────── Primera fila ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                icon: FontAwesomeIcons.clipboardList,
                label: 'Lista de chequeo',
                color: Colors.blue,
                enabled: state.ui.enableCheckList,
                onPressed: () async {
                  final ok = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return ChangeNotifierProvider(
                        create: (_) => ChecklistViewModel(
                          repo: ChecklistRepositoryImpl(ChecklistApi()),
                          serviceId: state.id,
                        ),
                        child: const _ChecklistModal(),
                      );
                    },
                  );

                  if (ok == true) {
                    context.read<DetailServiceViewModel>().loadDetail(state.id);
                  }
                },
              ),
              ActionButton(
                icon: FontAwesomeIcons.locationDot,
                label: 'Estatus soporte',
                color: Colors.red,
                enabled: state.ui.enableSupport,
                onPressed: state.ui.enableSupport
                    ? () async {
                        final updated = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => SupportStatusViewModel(
                              repo: SupportStatusRepositoryImpl(
                                SupportStatusApi(),
                              ),
                              serviceId: state.id,
                              statusId: state.statusId,
                              type: state.type,
                            ),
                            child: const Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: StatusSupportView(),
                            ),
                          ),
                        );

                        if (updated == true) {
                          context
                              .read<DetailServiceViewModel>()
                              .loadDetail(state.id);
                        }
                      }
                    : null,
              ),
              const ActionButton(
                icon: FontAwesomeIcons.mapLocationDot,
                label: 'Geocerca',
                color: Colors.grey,
                enabled: false,
                onPressed: null,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 16),

          // ─────────────── Segunda fila ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (e.serviceType == 'contenedor')
                ActionButton(
                  icon: FontAwesomeIcons.circleCheck,
                  label: 'Cierre de viaje',
                  color: Colors.green,
                  enabled: state.ui.serviceClosed,
                  onPressed: state.ui.serviceClosed
                      ? () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/trip-closure',
                            arguments: {
                              'id': e.id,
                              'serviceId': e.service,
                            },
                          );

                          if (result == true) {
                            onRefresh();
                          }
                        }
                      : null,
                ),
              ActionButton(
                icon: FontAwesomeIcons.moneyBillTransfer,
                label: 'Viáticos',
                color: Colors.teal,
                enabled: state.pendingMoneyChecks,
                onPressed: null,
              ),
              ActionButton(
                icon: FontAwesomeIcons.solidFilePdf,
                label: 'Descargar CCP',
                color: Colors.red,
                enabled: true,
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistModal extends StatelessWidget {
  const _ChecklistModal();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Lista de chequeo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            const Expanded(
              child: CheckListView(),
            ),
          ],
        ),
      ),
    );
  }
}

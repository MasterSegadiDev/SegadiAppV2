import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

import '../../../support_status/domain/entities/support_status_entity.dart';

class SupportStatusModal extends StatefulWidget {
  final String idRemision;
  final String idSolicitud;

  const SupportStatusModal({
    super.key,
    required this.idRemision,
    required this.idSolicitud,
  });

  @override
  State<SupportStatusModal> createState() => _SupportStatusModalState();
}

class _SupportStatusModalState extends State<SupportStatusModal> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportStatusViewModel>().loadStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportStatusViewModel>(
      builder: (
        context,
        vm,
        child,
      ) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 650,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: _buildContent(
                    context,
                    vm,
                  ),
                ),
                _buildFooter(
                  context,
                  vm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        12,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2C522A).withOpacity(.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2C522A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estatus de soporte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C522A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Selecciona el motivo del soporte',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SupportStatusViewModel vm,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: Color(0xFF2C522A),
          ),
        ),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 46,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'No pudimos cargar los estatus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: vm.loadStatuses,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Reintentar',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.statuses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No hay estatus de soporte disponibles.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      itemCount: vm.statuses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (
        context,
        index,
      ) {
        final status = vm.statuses[index];

        return _SupportStatusOption(
          status: status,
          selected: vm.selectedStatus?.id == status.id,
          onTap: () {
            vm.selectStatus(status);
          },
        );
      },
    );
  }

  Widget _buildFooter(
    BuildContext context,
    SupportStatusViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: vm.selectedStatus == null || vm.isSending
                  ? null
                  : () async {
                      final success = await vm.sendStatus(
                        referralId: widget.idRemision,
                        serviceRequestId: widget.idSolicitud,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      if (success) {
                        Navigator.pop(
                          context,
                          true,
                        );
                      }
                    },
              child: vm.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Enviar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportStatusOption extends StatelessWidget {
  final SupportStatusEntity status;
  final bool selected;
  final VoidCallback onTap;

  const _SupportStatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF2C522A).withOpacity(.08)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF2C522A) : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _StatusIcon(
                status: status.monitoringStatus,
                selected: selected,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.monitoringStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? const Color(0xFF2C522A) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Estatus de soporte',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color:
                    selected ? const Color(0xFF2C522A) : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  final bool selected;

  const _StatusIcon({
    required this.status,
    required this.selected,
  });

  IconData _getIcon() {
    final value = status.toLowerCase();

    if (value.contains('diesel') ||
        value.contains('combustible') ||
        value.contains('gasolina')) {
      return Icons.local_gas_station;
    }

    if (value.contains('comida') ||
        value.contains('comer') ||
        value.contains('alimento')) {
      return Icons.restaurant;
    }

    if (value.contains('baño') || value.contains('bano')) {
      return Icons.wc;
    }

    if (value.contains('dormir') ||
        value.contains('descanso') ||
        value.contains('descansar')) {
      return Icons.hotel;
    }

    if (value.contains('patio')) {
      return Icons.local_shipping;
    }

    return Icons.support_agent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2C522A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF2C522A) : Colors.grey.shade200,
        ),
      ),
      child: Icon(
        _getIcon(),
        color: selected ? Colors.white : const Color(0xFF2C522A),
      ),
    );
  }
}

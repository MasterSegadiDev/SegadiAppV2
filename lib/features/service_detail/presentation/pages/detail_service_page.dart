import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';

import 'package:segadi/features/evidence/presentation/pages/widgets/flow_evidence_page.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_info_row.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/service_detail/presentation/widgets/actions_card.dart';
import 'package:segadi/features/service_detail/presentation/widgets/info_row_tile_card.dart';
import 'package:segadi/features/service_detail/presentation/widgets/messages_error.dart';

class DetailServicePage extends StatefulWidget {
  final int serviceId;

  const DetailServicePage({
    super.key,
    required this.serviceId,
  });

  @override
  State<DetailServicePage> createState() => _DetailServicePageState();
}

class _DetailServicePageState extends State<DetailServicePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailServiceViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.navigateToSendEvidence) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EvidenceFlowPage(
              serviceId: vm.entity!.id,
            ),
          ),
        );
        vm.consumeNavigation();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle Remisión',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: _buildBody(vm),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.phone, color: Colors.white),
        onPressed: () => FlutterPhoneDirectCaller.callNumber('+523311364928'),
      ),
    );
  }

  Widget _buildBody(DetailServiceViewModel vm) {
    switch (vm.status) {
      case DetailServiceStatus.loading:
        return const Center(
          child: CupertinoActivityIndicator(radius: 14),
        );

      case DetailServiceStatus.error:
        return ErrorModalLauncher(
          message: vm.errorMessage ?? 'Ocurrió un error inesperado',
          onRetry: () => vm.retry(widget.serviceId),
        );

      case DetailServiceStatus.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _DetailContent(entity: vm.entity!),
              const SizedBox(height: 20),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _DetailContent extends StatelessWidget {
  final DetailServiceEntity entity;

  const _DetailContent({required this.entity});

  @override
  Widget build(BuildContext context) {
    final e = entity;
    print('detalle de servicio id ${e.id}');
    return Column(
      children: [
        _Header(service: e.service),
        const SizedBox(height: 20),
        _InfoCard(
          title: 'Remitente',
          rows: [
            InfoRow(
              icon: Icons.business,
              label: 'Razón Social',
              value: entity.senderBusinessName,
            ),
            InfoRow(
              icon: Icons.phone,
              label: 'Teléfono',
              value: entity.senderPhoneNumber,
            ),
            InfoRow(
              icon: Icons.person,
              label: 'Contacto',
              value: entity.senderName,
            ),
            InfoRow(
              icon: Icons.home,
              label: 'Domicilio',
              value:
                  '${entity.senderStreet} ${entity.senderOutdoorNumber} CP ${entity.senderZipCode}',
            ),
          ],
        ),

        _InfoCard(
          title: 'Destinatario',
          rows: [
            InfoRow(
                icon: Icons.business,
                label: 'Razón Social',
                value: entity.recipientBusinessName),
            InfoRow(
                icon: Icons.phone,
                label: 'Teléfono',
                value: entity.recipientPhoneNumber),
            InfoRow(
                icon: Icons.person,
                label: 'Contacto',
                value: entity.recipientName),
            InfoRow(
              icon: Icons.home,
              label: 'Domicilio',
              value:
                  '${entity.recipientStreet} ${entity.recipientOutdoorNumber}, CP ${entity.recipientZipCode}, ${entity.recipientState}',
            ),
          ],
        ),

        const SizedBox(height: 24),

        /// 4️⃣ ICONOS (ACCIONES)
        ActionsCard(
          ui: e,
          onRefresh: () => {}, // Acción de refrescar si es necesario
        ),

        const SizedBox(height: 24),

        /// 5️⃣ BOTÓN ESTATUS
        StatusPrimaryButton(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String service;

  const _Header({required this.service});

  @override
  Widget build(BuildContext context) {
    return Text(
      'REMISIÓN $service',
      style: TextStyle(fontSize: 20, color: Colors.black),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;

  const _InfoCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Título
          Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 12),

          // 🔹 Filas
          ...rows.map((row) => InfoRowTile(row)),
        ],
      ),
    );
  }
}

class StatusPrimaryButton extends StatelessWidget {
  const StatusPrimaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailServiceViewModel>();
    final state = vm.state;

    print('estatdo del boton ${state}');

    // Seguridad: si aún no hay estado
    if (state == null) {
      return const SizedBox.shrink();
    }

    final bool isEnabled =
        state.enableButton && vm.status != DetailServiceStatus.loading;

    return CupertinoButton.filled(
      borderRadius: BorderRadius.circular(100),
      onPressed: isEnabled ? () => vm.changeMandatoryStatus(context) : null,

      // 🎨 color cuando está deshabilitado
      disabledColor: CupertinoColors.systemGrey4,

      child: vm.status == DetailServiceStatus.loading
          ? const CupertinoActivityIndicator()
          : Text(
              state.buttonLabel, // 🔥 NUNCA vacío
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isEnabled ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
    );
  }
}

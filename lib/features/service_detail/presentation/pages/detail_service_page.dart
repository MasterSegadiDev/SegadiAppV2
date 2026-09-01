import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:segadi/features/evidence_old/presentation/pages/widgets/flow_evidence_page.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/service_detail/presentation/widgets/detail_content.dart';
import 'package:segadi/features/service_detail/presentation/widgets/error_message_view.dart';

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
  bool _alreadyNavigated = false;

  @override
  void initState() {
    super.initState();
    _alreadyNavigated = false;
    Future.microtask(() {
      context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);
    });
  }

  void _navigateToEvidences(BuildContext context, DetailServiceViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/flow_evidencias'),
        builder: (context) => EvidenceFlowPage(serviceId: vm.entity!.id),
      ),
    ).then((result) async {
      if (!mounted) return;

      if (result == true) {
        // 1. Ponemos el candado PRIMERO que nada
        context.read<DetailServiceViewModel>().markEvidenceAsUploaded();

        // 2. Esperamos un mini-delay de 500ms para que el backend "respire"
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 3. Ahora sí cargamos el detalle
      await context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailServiceViewModel>();

    // Lógica de navegación automática (solo la primera vez al entrar)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.navigateToSendEvidence && !_alreadyNavigated) {
        _alreadyNavigated = true;
        vm.consumeNavigation();
        _navigateToEvidences(context, vm);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle Remisión',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (vm.status == DetailServiceStatus.loaded &&
                vm.entity?.nextMandatoryStatusId == 10)
              _buildPendingActionBanner(context, vm),

            // --- CONTENIDO PRINCIPAL ---
            Expanded(
              child: _buildBody(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActionBanner(
      BuildContext context, DetailServiceViewModel vm) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Evidencias faltantes. Debe finalizar la remisión.",
              style: TextStyle(
                color: Color(0xFF856404),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToEvidences(context, vm),
            child: const Text(
              "CONTINUAR",
              style: TextStyle(
                  color: Color(0xFF2C522A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DetailServiceViewModel vm) {
    switch (vm.status) {
      case DetailServiceStatus.loading:
        return const Center(child: CupertinoActivityIndicator(radius: 14));

      case DetailServiceStatus.error:
        return ErrorMessageView(
          message: vm.errorMessage ?? 'Ocurrió un error inesperado',
          onRetry: () => vm.retry(widget.serviceId),
        );

      case DetailServiceStatus.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: DetailContent(entity: vm.entity!),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

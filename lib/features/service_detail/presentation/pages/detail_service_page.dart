import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:segadi/features/evidence/presentation/pages/widgets/flow_evidence_page.dart';
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

  /// Método centralizado para navegar al flujo de evidencias
  void _navigateToEvidences(BuildContext context, DetailServiceViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/detail_service'),
        builder: (context) => EvidenceFlowPage(serviceId: vm.entity!.id),
      ),
    ).then((_) async {
      // 1. PRIMERA PROTECCIÓN: ¿La pantalla de detalle sigue existiendo?
      if (!mounted) return;

      // 2. RECARGAMOS:
      // Usamos context.read para asegurarnos de tener la instancia activa
      await context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);

      // 3. SEGUNDA PROTECCIÓN:
      // Después de un await largo, la pantalla pudo haberse cerrado.
      if (!mounted) return;

      final currentVm = context.read<DetailServiceViewModel>();

      // 4. VALIDAMOS:
      if (currentVm.entity?.statusId == 10) {
        // Si sigue en 10, el chofer canceló. Lo sacamos al listado.
        Navigator.of(context).pop();
      } else {
        print("Permanecemos en detalle: flujo exitoso.");
      }
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
            // --- BANNER PROFESIONAL DE ACCIÓN PENDIENTE ---
            if (vm.status == DetailServiceStatus.loaded &&
                vm.entity?.nextMandatoryStatusId == 10)
              Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Confirmación de entrega pendiente",
                        style: TextStyle(
                          color: Color(0xFF856404),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToEvidences(context, vm),
                      child: const Text(
                        "CONTINUAR",
                        style: TextStyle(
                            color: Color(0xFF2C522A),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // --- CONTENIDO PRINCIPAL ---
            Expanded(
              child: _buildBody(vm),
            ),
          ],
        ),
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

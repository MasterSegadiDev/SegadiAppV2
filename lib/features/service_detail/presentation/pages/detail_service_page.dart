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
  // void _navigateToEvidences(BuildContext context, DetailServiceViewModel vm) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       settings: const RouteSettings(name: '/flow_evidencias'),
  //       builder: (context) => EvidenceFlowPage(serviceId: vm.entity!.id),
  //     ),
  //   ).then((_) async {
  //     // 1. Verificamos si la pantalla sigue montada
  //     if (!mounted) return;

  //     // 2. RECARGAMOS LOS DATOS
  //     // Esto actualizará el 'nextMandatoryStatusId' desde el servidor
  //     await context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);

  //     // 3. LÓGICA DE DECISIÓN POST-FLUJO
  //     if (!mounted) return;
  //     final currentVm = context.read<DetailServiceViewModel>();

  //     // Si el statusId ya NO es 10, significa que la remisión se finalizó con éxito en el servidor
  //     if (currentVm.entity?.statusId != 10) {
  //       // OPCIONAL: Podrías mostrar un Snackbar de éxito aquí
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Servicio finalizado con éxito")),
  //       );
  //       // Regresamos al listado porque el trabajo aquí terminó
  //       Navigator.of(context).pop();
  //     } else {
  //       // Si sigue en 10, es porque el usuario regresó voluntariamente (back button)
  //       // No hacemos nada, permitimos que el Banner de 'CONTINUAR' haga su trabajo.
  //       print(
  //           "El usuario regresó sin finalizar. Mostrando banner de pendiente.");
  //     }
  //   });
  // }

  void _navigateToEvidences(BuildContext context, DetailServiceViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/flow_evidencias'),
        builder: (context) => EvidenceFlowPage(serviceId: vm.entity!.id),
      ),
    ).then((_) async {
      // 1. Verificamos si la pantalla de detalle sigue ahí
      if (!mounted) return;

      // 2. CARGAMOS LOS DATOS (El "load" que necesitas)
      // Esto refresca el detalle con la info nueva del servidor
      await context.read<DetailServiceViewModel>().loadDetail(widget.serviceId);

      debugPrint(
          "Refresco de detalle completado. Permaneciendo en la pantalla.");
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

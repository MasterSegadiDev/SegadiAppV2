import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:segadi/features/evidence/presentation/pages/widgets/flow_evidence_page.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/service_detail/presentation/widgets/detail_content.dart';
import 'package:segadi/features/service_detail/presentation/widgets/error_message_view.dart';
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
    print('estatus de viaticos asigandos ${vm.entity?.pendingMoneyChecks}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.navigateToSendEvidence) {
        Navigator.push(
          context,
          MaterialPageRoute(
            // 1. Le ponemos nombre a esta "puerta de salida"
            settings: const RouteSettings(name: '/detail_service'),
            builder: (context) => EvidenceFlowPage(
              serviceId: vm.entity!.id,
            ),
          ),
        ).then((_) {
          // 2. Cuando el usuario regrese (de cualquier forma), recargamos
          vm.loadDetail(vm.entity!.id);
        });

        Future.microtask(() {
          if (!mounted) return;
          vm.consumeNavigation();
        });
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   child: const Icon(Icons.phone, color: Colors.white),
      //   onPressed: () => FlutterPhoneDirectCaller.callNumber('+523311364928'),
      // ),
    );
  }

  Widget _buildBody(DetailServiceViewModel vm) {
    switch (vm.status) {
      case DetailServiceStatus.loading:
        return const Center(
          child: CupertinoActivityIndicator(radius: 14),
        );

      case DetailServiceStatus.error:
        // ✅ CAMBIO AQUÍ: Ahora se muestra en pantalla directamente
        return ErrorMessageView(
          message: vm.errorMessage ?? 'Ocurrió un error inesperado',
          onRetry: () => vm.retry(widget.serviceId),
        );

      case DetailServiceStatus.loaded:
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: DetailContent(entity: vm.entity!),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

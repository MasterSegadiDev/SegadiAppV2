import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/recipient_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/sender_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_actions_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_header_card.dart';
import 'package:segadi/features/services/presentation/widgets/service_detail/service_status_button.dart';

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
            ServiceActionsCard(),
            ServiceStatusButton(
              status: '',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/services_provider.dart';
import '../widgets/service_card.dart';
import '../widgets/services_empty.dart';
import '../widgets/services_error.dart';
import '../widgets/services_loading.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({
    super.key,
  });

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(servicesProvider.notifier).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis servicios',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(servicesProvider.notifier).loadServices();
        },
        child: Builder(
          builder: (_) {
            if (state.isLoading) {
              return const ServicesLoading();
            }

            if (state.error != null) {
              return ServicesError(
                message: state.error!,
                onRetry: () {
                  ref.read(servicesProvider.notifier).loadServices();
                },
              );
            }

            if (state.services.isEmpty) {
              return const ServicesEmpty();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.services.length,
              itemBuilder: (_, index) {
                final service = state.services[index];

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: ServiceCard(
                    service: service,
                    onTap: () {
                      // TODO
                      // Ir al detalle
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

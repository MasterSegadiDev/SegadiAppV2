import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/services_provider.dart';
import '../widgets/service_card.dart';
import '../widgets/services_empty.dart';
import '../widgets/services_error.dart';
import '../widgets/services_loading.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  // Variable para almacenar lo que el usuario escribe en el buscador
  String _searchQuery = '';

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
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar servicio...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // --- CONTENIDO DE LA LISTA / ESTADOS ---
          Expanded(
            child: RefreshIndicator(
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

                  final query = _searchQuery.toLowerCase().trim();
                  final filteredServices = state.services.where((item) {
                    if (query.isEmpty) return true;
                    return (item.serviceNumber).toLowerCase().contains(query) ||
                        (item.customer).toLowerCase().contains(query) ||
                        (item.origin).toLowerCase().contains(query) ||
                        (item.destination).toLowerCase().contains(query);
                  }).toList();

                  // Si tras buscar no hay resultados, mostramos un aviso
                  if (filteredServices.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron servicios con ese nombre'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredServices.length,
                    itemBuilder: (_, index) {
                      final service = filteredServices[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ServiceCard(
                          service: service,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

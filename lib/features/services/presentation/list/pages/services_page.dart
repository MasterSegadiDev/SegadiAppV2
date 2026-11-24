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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    Future.microtask(() {
      ref.read(servicesProvider.notifier).loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);

    return RefreshIndicator(
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(servicesProvider.notifier).searchServices(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar remisión, origen o destino',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();

                              ref.read(servicesProvider.notifier).clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: state.filteredServices.isEmpty
                    ? const ServicesEmpty()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredServices.length,
                        itemBuilder: (_, index) {
                          final service = state.filteredServices[index];

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: ServiceCard(
                              service: service,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

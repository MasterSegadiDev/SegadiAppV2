import 'package:flutter/material.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/services_assigned/presentation/widgets/service_card.dart';

Widget buildBody(ServicesViewModel vm) {
  return RefreshIndicator(
    onRefresh: vm.loadServices,
    child: switch (vm.state) {
      ServicesLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      ServicesEmpty() => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text('No hay servicios disponibles')),
          ],
        ),
      ServicesLoaded(:final items) => ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: items.length,
          itemBuilder: (_, i) => ServiceCard(item: items[i]),
        ),
      ServicesError(:final message) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.loadServices,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      // TODO: Handle this case.
      ServicesInitial() => throw UnimplementedError(),
    },
  );
}

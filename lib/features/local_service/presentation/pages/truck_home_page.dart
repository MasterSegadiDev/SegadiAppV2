import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';

class TruckHomePage extends ConsumerStatefulWidget {
  final String operadorId;

  const TruckHomePage({
    super.key,
    required this.operadorId,
  });

  @override
  ConsumerState<TruckHomePage> createState() => _TruckHomePageState();
}

class _TruckHomePageState extends ConsumerState<TruckHomePage> {
  @override
  void initState() {
    super.initState();

    // Esperamos a que termine el primer frame
    // antes de modificar el provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(tramoProvider.notifier).load(widget.operadorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tramoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi viaje'),
      ),
      body: switch (state) {
        TramoInitial() || TramoLoading() => const _LoadingView(),
        TramoEmpty() => const _EmptyView(),
        TramoLoaded(:final tramo) => RefreshIndicator(
            onRefresh: () {
              return ref.read(tramoProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Viaje activo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tramo.status.apiValue,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        _InfoRow(
                          label: 'Operador',
                          value: tramo.operadorName,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Unidad',
                          value: tramo.unidadId,
                        ),
                        if (tramo.contenedores.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: 'Contenedor',
                            value: tramo.contenedores.first.numero,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              context.push(
                                AppRoutes.tramoDetail,
                              );
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                            ),
                            label: const Text(
                              'Ver detalle',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        TramoError(:final message) => _ErrorView(message: message),
      },
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// ============================================================
// SIN TRAMO
// ============================================================

class _EmptyView extends ConsumerWidget {
  const _EmptyView();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.read(tramoProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.local_shipping_outlined,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'Sin viaje asignado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Actualmente no tienes un tramo activo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo o presiona '
            'Actualizar para consultar nuevamente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.read(tramoProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends ConsumerWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.read(tramoProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No fue posible cargar el tramo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(tramoProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Intentar nuevamente',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILA DE INFORMACIÓN
// ============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}

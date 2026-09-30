import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';
import 'package:segadi/features/local_service/presentation/widgets/tramo_action.dart';

class TramoDetailPage extends ConsumerWidget {
  const TramoDetailPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(tramoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del tramo',
        ),
      ),
      body: switch (state) {
        TramoLoaded(
          :final tramo,
          :final updatingStatus,
        ) =>
          RefreshIndicator(
            onRefresh: () {
              return ref.read(tramoProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ============================================
                // ESTADO
                // ============================================

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado actual',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tramo.status.apiValue,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // INFORMACIÓN GENERAL
                // ============================================

                Text(
                  'Información del viaje',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                        ),
                        title: const Text('Operador'),
                        subtitle: Text(
                          tramo.operadorName,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.local_shipping_outlined,
                        ),
                        title: const Text('Unidad'),
                        subtitle: Text(
                          tramo.unidadId,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // CONTENEDORES
                // ============================================

                Text(
                  'Contenedores',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                if (tramo.contenedores.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay contenedores registrados.',
                      ),
                    ),
                  )
                else
                  ...tramo.contenedores.map(
                    (contenedor) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.inventory_2_outlined,
                          ),
                          title: Text(
                            contenedor.numero,
                          ),
                          subtitle: Text(
                            'Tamaño: ${contenedor.tamano}',
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // ============================================
                // PARADAS
                // ============================================

                Text(
                  'Ruta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                if (tramo.paradas.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay paradas registradas.',
                      ),
                    ),
                  )
                else
                  ...tramo.paradas.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final parada = entry.value;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                            ),
                          ),
                          title: Text(
                            parada.domicilio,
                          ),
                          subtitle: Text(
                            '${parada.tipo.apiValue}'
                            ' • '
                            '${parada.accion.apiValue}',
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // ============================================
                // ACCIÓN SEGÚN ESTADO
                // ============================================

                TramoAction(
                  tramo: tramo,
                  loading: updatingStatus,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        TramoLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        TramoEmpty() => const _NoTramoView(),
        TramoError(:final message) => _DetailErrorView(
            message: message,
          ),
        TramoInitial() => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }
}

class _NoTramoView extends StatelessWidget {
  const _NoTramoView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'El tramo ya no está activo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailErrorView extends ConsumerWidget {
  final String message;

  const _DetailErrorView({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }
}

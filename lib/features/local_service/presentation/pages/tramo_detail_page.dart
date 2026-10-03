import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';
import 'package:segadi/features/local_service/presentation/widgets/tramo_action.dart';

// ============================================================
// COLORES
// ============================================================

class _C {
  static const background = Color(0xFFF7F8F6);

  static const surfaceDark = Color(0xFF101812);

  static const primaryGreen = Color(0xFF1E7A3C);
  static const primaryGreenSoft = Color(0xFFE1F0E3);

  static const textPrimary = Color(0xFF101812);
  static const textSecondary = Color(0xFF6B6B66);
  static const textMuted = Color(0xFF9A9A94);

  static const border = Color(0xFFE0E0DA);

  static const errorRed = Color(0xFFB23A3A);
}

// ============================================================
// TRAMO DETAIL PAGE
// ============================================================

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
      backgroundColor: _C.background,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: _C.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Detalle del tramo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: switch (state) {
        TramoLoaded(
          :final tramo,
          :final updatingStatus,
        ) =>
          RefreshIndicator(
            color: _C.primaryGreen,
            onRefresh: () {
              return ref.read(tramoProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ==================================================
                // TITULO
                // ==================================================

                const Text(
                  'Viaje activo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TARJETA PRINCIPAL
                // ==================================================

                Container(
                  decoration: _cardDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        // ------------------------------------------
                        // HEADER VERDE
                        // ------------------------------------------

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: _C.primaryGreenSoft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                size: 18,
                                color: _C.primaryGreen,
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Text(
                                  'VIAJE ACTIVO',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                    color: _C.surfaceDark,
                                  ),
                                ),
                              ),

                              // STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.primaryGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tramo.status.apiValue.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ------------------------------------------
                        // INFORMACIÓN PRINCIPAL
                        // ------------------------------------------

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Operador',
                                value: tramo.operadorName,
                              ),
                              const SizedBox(height: 14),
                              _InfoRow(
                                icon: Icons.local_shipping_outlined,
                                label: 'Unidad',
                                value: tramo.unidadId,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // CONTENEDORES
                // ==================================================

                _SectionHeader(
                  icon: Icons.inventory_2_outlined,
                  title: 'Contenedores',
                  count: tramo.contenedores.length,
                ),

                const SizedBox(height: 10),

                if (tramo.contenedores.isEmpty)
                  _EmptySectionCard(
                    icon: Icons.inventory_2_outlined,
                    text: 'No hay contenedores registrados.',
                  )
                else
                  Container(
                    decoration: _cardDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < tramo.contenedores.length;
                              i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                thickness: .5,
                                color: _C.border,
                              ),
                            _ContainerTile(
                              numero: tramo.contenedores[i].numero,
                              tamano: tramo.contenedores[i].tamano,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 26),

                // ==================================================
                // RUTA
                // ==================================================

                _SectionHeader(
                  icon: Icons.route_outlined,
                  title: 'Ruta',
                  count: tramo.paradas.length,
                ),

                const SizedBox(height: 10),

                if (tramo.paradas.isEmpty)
                  _EmptySectionCard(
                    icon: Icons.location_off_outlined,
                    text: 'No hay paradas registradas.',
                  )
                else
                  Container(
                    decoration: _cardDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        4,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < tramo.paradas.length; i++)
                            _ParadaTimelineTile(
                              index: i,
                              isLast: i == tramo.paradas.length - 1,
                              domicilio: tramo.paradas[i].domicilio,
                              tipo: tramo.paradas[i].tipo.apiValue,
                              accion: tramo.paradas[i].accion.apiValue,
                            ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // ==================================================
                // ACCIÓN
                // ==================================================

                const _SectionHeader(
                  icon: Icons.touch_app_outlined,
                  title: 'Acciones del viaje',
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: TramoAction(
                    tramo: tramo,
                    loading: updatingStatus,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

        // ======================================================
        // LOADING
        // ======================================================

        TramoLoading() => const _LoadingView(),
        TramoInitial() => const _LoadingView(),

        // ======================================================
        // VACÍO
        // ======================================================

        TramoEmpty() => const _NoTramoView(),

        // ======================================================
        // ERROR
        // ======================================================

        TramoError(:final message) => _DetailErrorView(
            message: message,
          ),
      },
    );
  }
}

// ============================================================
// DECORACIÓN GENERAL DE TARJETAS
// ============================================================

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: _C.surfaceDark.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ============================================================
// HEADER DE SECCIÓN
// ============================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.primaryGreenSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: _C.primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _C.primaryGreenSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _C.primaryGreen,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// FILA DE INFORMACIÓN PRINCIPAL
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ICONO
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.primaryGreenSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: _C.primaryGreen,
          ),
        ),

        const SizedBox(width: 12),

        // TEXTO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _C.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CONTENEDOR
// ============================================================

class _ContainerTile extends StatelessWidget {
  final String numero;
  final String tamano;

  const _ContainerTile({
    required this.numero,
    required this.tamano,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          // ICONO
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _C.primaryGreenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: _C.primaryGreen,
            ),
          ),

          const SizedBox(width: 12),

          // INFORMACIÓN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  numero,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tamaño: $tamano',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.inventory_2_outlined,
            size: 16,
            color: _C.textMuted,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIMELINE DE PARADAS
// ============================================================

class _ParadaTimelineTile extends StatelessWidget {
  final int index;
  final bool isLast;
  final String domicilio;
  final String tipo;
  final String accion;

  const _ParadaTimelineTile({
    required this.index,
    required this.isLast,
    required this.domicilio,
    required this.tipo,
    required this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // TIMELINE
        // ======================================================

        SizedBox(
          width: 32,
          child: Column(
            children: [
              // CÍRCULO
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _C.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // LÍNEA
              if (!isLast)
                Container(
                  width: 2,
                  height: 62,
                  color: _C.primaryGreenSoft,
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ======================================================
        // INFORMACIÓN
        // ======================================================

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
              top: 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PARADA
                Text(
                  'Parada ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.primaryGreen,
                  ),
                ),

                const SizedBox(height: 4),

                // DOMICILIO
                Text(
                  domicilio,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                // TIPO / ACCIÓN
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _RouteBadge(
                      text: tipo,
                    ),
                    _RouteBadge(
                      text: accion,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BADGE DE RUTA
// ============================================================

class _RouteBadge extends StatelessWidget {
  final String text;

  const _RouteBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _C.primaryGreenSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _C.primaryGreen,
        ),
      ),
    );
  }
}

// ============================================================
// SECCIÓN VACÍA
// ============================================================

class _EmptySectionCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptySectionCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _C.primaryGreenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: _C.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: _C.textMuted,
              ),
            ),
          ),
        ],
      ),
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
      child: CircularProgressIndicator(
        color: _C.primaryGreen,
        strokeWidth: 2.4,
      ),
    );
  }
}

// ============================================================
// SIN TRAMO
// ============================================================

class _NoTramoView extends ConsumerWidget {
  const _NoTramoView();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      color: _C.primaryGreen,
      onRefresh: () {
        return ref.read(tramoProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: _C.primaryGreenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 38,
                color: _C.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'El tramo ya no está activo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Actualmente no tienes información de un tramo activo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Desliza hacia abajo o presiona Actualizar '
            'para consultar nuevamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _C.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(tramoProvider.notifier).refresh();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textPrimary,
                side: const BorderSide(
                  color: _C.border,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: _C.primaryGreen,
              ),
              label: const Text(
                'Actualizar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

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
    return RefreshIndicator(
      color: _C.primaryGreen,
      onRefresh: () {
        return ref.read(tramoProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _C.errorRed.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: _C.errorRed,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No fue posible cargar el tramo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(tramoProvider.notifier).refresh();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textPrimary,
                side: const BorderSide(
                  color: _C.border,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: _C.primaryGreen,
              ),
              label: const Text(
                'Intentar nuevamente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

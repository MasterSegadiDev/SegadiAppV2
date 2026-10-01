import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';
import 'package:segadi/features/local_service/presentation/widgets/tramo_action.dart';

// Paleta central usada en toda la app.
// TODO: si ya creaste app_colors.dart, borra esto e importa de ahí.
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

/// Esta pantalla se abre con context.push, fuera del shell de MainLayout,
/// así que sí conserva su propio Scaffold/AppBar (con flecha de back).
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
      appBar: AppBar(
        backgroundColor: _C.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detalle del tramo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
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
                // ============================================
                // ESTADO
                // ============================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estado actual',
                        style: TextStyle(
                          fontSize: 13,
                          color: _C.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _C.primaryGreenSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tramo.status.apiValue,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // INFORMACIÓN GENERAL
                // ============================================

                const _SectionLabel('INFORMACIÓN DEL VIAJE'),
                const SizedBox(height: 8),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _DetailTile(
                        icon: Icons.person_outline,
                        title: 'Operador',
                        subtitle: tramo.operadorName,
                      ),
                      const Divider(height: 1, color: _C.border),
                      _DetailTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Unidad',
                        subtitle: tramo.unidadId,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // CONTENEDORES
                // ============================================

                const _SectionLabel('CONTENEDORES'),
                const SizedBox(height: 8),

                if (tramo.contenedores.isEmpty)
                  const _EmptySectionCard(
                    text: 'No hay contenedores registrados.',
                  )
                else
                  Container(
                    decoration: _cardDecoration(),
                    child: Column(
                      children: [
                        for (var i = 0; i < tramo.contenedores.length; i++) ...[
                          if (i > 0) const Divider(height: 1, color: _C.border),
                          _DetailTile(
                            icon: Icons.inventory_2_outlined,
                            title: tramo.contenedores[i].numero,
                            subtitle: 'Tamaño: ${tramo.contenedores[i].tamano}',
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ============================================
                // PARADAS
                // ============================================

                const _SectionLabel('RUTA'),
                const SizedBox(height: 8),

                if (tramo.paradas.isEmpty)
                  const _EmptySectionCard(
                    text: 'No hay paradas registradas.',
                  )
                else
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    decoration: _cardDecoration(),
                    child: Column(
                      children: [
                        for (var i = 0; i < tramo.paradas.length; i++)
                          _ParadaTimelineTile(
                            index: i,
                            isLast: i == tramo.paradas.length - 1,
                            domicilio: tramo.paradas[i].domicilio,
                            detalle: '${tramo.paradas[i].tipo.apiValue} • '
                                '${tramo.paradas[i].accion.apiValue}',
                          ),
                      ],
                    ),
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
            child: CircularProgressIndicator(color: _C.primaryGreen),
          ),
        TramoEmpty() => const _NoTramoView(),
        TramoError(:final message) => _DetailErrorView(
            message: message,
          ),
        TramoInitial() => const Center(
            child: CircularProgressIndicator(color: _C.primaryGreen),
          ),
      },
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: _C.surfaceDark.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// ============================================================
// LABEL DE SECCIÓN
// ============================================================

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _C.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ============================================================
// TILE DE DETALLE (reemplaza ListTile)
// ============================================================

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Icon(icon, size: 17, color: _C.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: _C.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PARADA EN TIMELINE
// ============================================================

class _ParadaTimelineTile extends StatelessWidget {
  final int index;
  final bool isLast;
  final String domicilio;
  final String detalle;

  const _ParadaTimelineTile({
    required this.index,
    required this.isLast,
    required this.domicilio,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _C.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: _C.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domicilio,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: const TextStyle(fontSize: 12, color: _C.textSecondary),
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
// TARJETA VACÍA (contenedores/paradas sin datos)
// ============================================================

class _EmptySectionCard extends StatelessWidget {
  final String text;

  const _EmptySectionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: _C.textMuted),
      ),
    );
  }
}

// ============================================================
// SIN TRAMO
// ============================================================

class _NoTramoView extends StatelessWidget {
  const _NoTramoView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
            const SizedBox(height: 20),
            const Text(
              'El tramo ya no está activo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _C.textPrimary,
              ),
            ),
          ],
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _C.textSecondary),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(tramoProvider.notifier).refresh();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textPrimary,
                side: const BorderSide(color: _C.border),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18, color: _C.primaryGreen),
              label: const Text(
                'Intentar nuevamente',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

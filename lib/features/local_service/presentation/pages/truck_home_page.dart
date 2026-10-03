import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/states/stretch_state.dart';

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

class TruckHomePage extends ConsumerStatefulWidget {
  const TruckHomePage({
    super.key,
  });

  @override
  ConsumerState<TruckHomePage> createState() => _TruckHomePageState();
}

class _TruckHomePageState extends ConsumerState<TruckHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(tramoProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tramoProvider);

    return Container(
      color: _C.background,
      child: switch (state) {
        TramoInitial() || TramoLoading() => const _LoadingView(),
        TramoEmpty() => const _EmptyView(),
        TramoLoaded(:final tramo) => RefreshIndicator(
            color: _C.primaryGreen,
            onRefresh: () {
              return ref.read(tramoProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Viaje activo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _TripCard(
                  status: tramo.status.apiValue,
                  operador: tramo.operadorName,
                  unidad: tramo.unidadId,
                  contenedor: tramo.contenedores.isNotEmpty
                      ? tramo.contenedores.first.numero
                      : null,
                  onVerDetalle: () {
                    context.push(AppRoutes.tramoDetail);
                  },
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
// TARJETA DE VIAJE
// ============================================================

class _TripCard extends StatelessWidget {
  final String status;
  final String operador;
  final String unidad;
  final String? contenedor;
  final VoidCallback onVerDetalle;

  const _TripCard({
    required this.status,
    required this.operador,
    required this.unidad,
    required this.contenedor,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVerDetalle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.surfaceDark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoSection(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child:
                          Divider(height: 1, thickness: .5, color: _C.border),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: .5,
                color: _C.surfaceDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _C.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Operador',
          value: operador,
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.local_shipping_outlined,
          label: 'Unidad',
          value: unidad,
        ),
        if (contenedor != null) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            label: 'Contenedor',
            value: contenedor!,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Toca para ver el detalle completo',
            style: TextStyle(fontSize: 12, color: _C.textMuted),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: _C.textMuted,
        ),
      ],
    );
  }
}

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _C.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _C.textPrimary,
            ),
          ),
        ),
      ],
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

class _EmptyView extends ConsumerWidget {
  const _EmptyView();

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
            'Sin viaje asignado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Actualmente no tienes un tramo activo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Desliza hacia abajo o presiona Actualizar '
            'para consultar nuevamente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _C.textMuted),
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(tramoProvider.notifier).refresh();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textPrimary,
                side: const BorderSide(color: _C.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18, color: _C.primaryGreen),
              label: const Text(
                'Actualizar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
              fontWeight: FontWeight.w500,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
          const SizedBox(height: 22),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(tramoProvider.notifier).refresh();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textPrimary,
                side: const BorderSide(color: _C.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
          ),
        ],
      ),
    );
  }
}

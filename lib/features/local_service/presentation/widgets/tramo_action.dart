import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/local_service/domain/entities/stretch.dart';
import 'package:segadi/features/local_service/domain/enums/tramo_status.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';
import 'package:segadi/features/local_service/presentation/widgets/confirmation_dialog.dart';

class TramoAction extends ConsumerWidget {
  final Tramo tramo;
  final bool loading;

  const TramoAction({
    super.key,
    required this.tramo,
    required this.loading,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (loading) {
      return const _UpdatingStatusView();
    }

    return switch (tramo.status) {
      // ============================================
      // ASIGNADO
      // ============================================

      TramoStatus.asignado => _StatusButton(
          text: 'Iniciar viaje',
          icon: Icons.play_arrow,
          onPressed: () {
            _confirmStatusChange(
              context: context,
              ref: ref,
              title: 'Iniciar viaje',
              message: '¿Confirmas que deseas iniciar este viaje?',
              newStatus: TramoStatus.enTransito,
            );
          },
        ),

      // ============================================
      // EN TRANSITO
      // ============================================

      TramoStatus.enTransito => _StatusButton(
          text: 'Reportar llegada',
          icon: Icons.location_on_outlined,
          onPressed: () {
            _confirmStatusChange(
              context: context,
              ref: ref,
              title: 'Reportar llegada',
              message: '¿Confirmas que has llegado al destino?',
              newStatus: TramoStatus.llegadaPatio,
            );
          },
        ),

      // ============================================
      // LLEGADA PATIO
      // ============================================

      TramoStatus.llegadaPatio => _StatusButton(
          text: 'Solicitar maniobra',
          icon: Icons.precision_manufacturing_outlined,
          onPressed: () {
            _confirmStatusChange(
              context: context,
              ref: ref,
              title: 'Solicitar maniobra',
              message: '¿Confirmas que estás listo '
                  'para iniciar la maniobra?',
              newStatus: TramoStatus.esperandoGrua,
            );
          },
        ),

      // ============================================
      // ESPERANDO GRUA
      // ============================================

      // TramoStatus.esperandoGrua => const _WaitingCraneView(),

      TramoStatus.esperandoGrua => _StatusButton(
          text: 'Maniobra finalizada',
          icon: Icons.precision_manufacturing_outlined,
          onPressed: () {
            _confirmStatusChange(
              context: context,
              ref: ref,
              title: 'Maniobra finalizada',
              message: '¿Confirmas que estás listo '
                  'para finalizar la maniobra?',
              newStatus: TramoStatus.cargaConfirmada,
            );
          },
        ),

      // ============================================
      // CARGA CONFIRMADA
      // ============================================

      TramoStatus.cargaConfirmada => _StatusButton(
          text: 'Finalizar tramo',
          icon: Icons.check_circle_outline,
          onPressed: () {
            _confirmStatusChange(
              context: context,
              ref: ref,
              title: 'Finalizar tramo',
              message: '¿Confirmas que deseas finalizar '
                  'este tramo?',
              newStatus: TramoStatus.finalizado,
            );
          },
        ),

      // ============================================
      // FINALIZADO
      // ============================================

      TramoStatus.finalizado => const _FinishedView(),
    };
  }

  Future<void> _confirmStatusChange({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String message,
    required TramoStatus newStatus,
  }) async {
    final confirmed =
        await ConfirmationDialog.show(context, title: title, message: message);

    if (confirmed != true) {
      return;
    }

    final success =
        await ref.read(tramoProvider.notifier).changeStatus(newStatus);

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Estado actualizado correctamente.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No fue posible actualizar el estado.',
        ),
      ),
    );
  }
}

// ============================================================
// BOTÓN
// ============================================================

class _StatusButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

// ============================================================
// ACTUALIZANDO
// ============================================================

class _UpdatingStatusView extends StatelessWidget {
  const _UpdatingStatusView();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Actualizando estado...',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ESPERANDO GRÚA
// ============================================================

class _WaitingCraneView extends ConsumerWidget {
  const _WaitingCraneView();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.precision_manufacturing_outlined,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Esperando maniobra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'La maniobra de grúa está '
              'pendiente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(
                      tramoProvider.notifier,
                    )
                    .refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FINALIZADO
// ============================================================

class _FinishedView extends StatelessWidget {
  const _FinishedView();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
            ),
            SizedBox(height: 16),
            Text(
              'Tramo finalizado',
            ),
          ],
        ),
      ),
    );
  }
}

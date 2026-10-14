import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';

import '../../domain/entities/travel_expense_concept.dart';
import '../providers/travel_expenses_provider.dart';
import '../widgets/add_expense_bottom_sheet.dart';

class TravelExpensesPage extends ConsumerWidget {
  final ServiceDetailArguments arguments;
  const TravelExpensesPage({
    required this.arguments,
    super.key,
  });

  // =========================
  // COLORES
  // =========================

  static const Color green = Color(0xFF1E7A3C);
  static const Color dark = Color(0xFF101812);
  static const Color background = Color(0xFFF7F8F6);
  static const Color softGreen = Color(0xFFE1F0E3);
  static const Color secondaryText = Color(0xFF6B6B66);
  static const Color mutedText = Color(0xFF9A9A94);
  static const Color borderColor = Color(0xFFE0E0DA);

  // =========================
  // ABRIR BOTTOM SHEET
  // =========================

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    TravelExpenseConcept item,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => AddExpenseBottomSheet(
        requestId: arguments.idSolicitud,
        concept: item,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        travelExpenseConceptsProvider(arguments.idSolicitud),
      );
    }
  }

  // =========================
  // FORMATO MONEDA
  // =========================

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  // =========================
  // FORMATO FECHA
  // =========================

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year}  '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }

  // =========================
  // ICONO POR CONCEPTO
  // =========================

  IconData _conceptIcon(String concept) {
    final name = concept.toLowerCase();

    if (name.contains('alimento') || name.contains('comida')) {
      return Icons.restaurant_outlined;
    }

    if (name.contains('caseta') || name.contains('peaje')) {
      return Icons.route_outlined;
    }

    if (name.contains('combustible') ||
        name.contains('diesel') ||
        name.contains('gasolina')) {
      return Icons.local_gas_station_outlined;
    }

    if (name.contains('hospedaje') || name.contains('hotel')) {
      return Icons.hotel_outlined;
    }

    if (name.contains('estacionamiento')) {
      return Icons.local_parking_outlined;
    }

    if (name.contains('transporte')) {
      return Icons.local_shipping_outlined;
    }

    return Icons.receipt_long_outlined;
  }

  // =========================
  // VER EVIDENCIA
  // =========================

  void _showEvidence(
    BuildContext context,
    TravelExpenseConcept item,
  ) {
    final imageUrl = item.fileUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  12,
                  12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      color: green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.concept,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: dark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                color: borderColor,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const SizedBox(
                            height: 240,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: green,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No se pudo cargar la evidencia.',
                                style: TextStyle(
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // RESUMEN SUPERIOR
  // =========================

  Widget _buildSummary(
    List<TravelExpenseConcept> items,
  ) {
    final totalAuthorized = items.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final totalUsed = items.fold<double>(
      0,
      (sum, item) => sum + (item.evidenceAmount ?? 0),
    );

    final registeredCount = items
        .where(
          (item) => item.isRegistered,
        )
        .length;

    final progress = totalAuthorized > 0
        ? (totalUsed / totalAuthorized).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 19,
                color: green,
              ),
              SizedBox(width: 8),
              Text(
                'RESUMEN DE VIÁTICOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Total autorizado',
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _money(totalAuthorized),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: dark,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  label: 'Importe utilizado',
                  value: _money(totalUsed),
                  valueColor: green,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: borderColor,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              Expanded(
                child: _summaryValue(
                  label: 'Disponible',
                  value: _money(
                    totalAuthorized - totalUsed,
                  ),
                  valueColor: dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: softGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(
                green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 15,
                color: green,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$registeredCount de ${items.length} '
                  'conceptos registrados',
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // =========================
  // TARJETA DE VIÁTICO
  // =========================

  Widget _buildExpenseCard(
    BuildContext context,
    WidgetRef ref,
    TravelExpenseConcept item,
  ) {
    final isRegistered = item.isRegistered;
    final hasEvidence = item.fileUrl != null && item.fileUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: softGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _conceptIcon(item.concept),
                  color: green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.concept,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          isRegistered
                              ? Icons.check_circle
                              : Icons.schedule_outlined,
                          size: 14,
                          color: isRegistered ? green : secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isRegistered
                              ? 'Registrado'
                              : 'Pendiente de comprobar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isRegistered ? green : secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isRegistered
                    ? Icons.verified_outlined
                    : Icons.receipt_long_outlined,
                color: isRegistered ? green : mutedText,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: borderColor,
          ),

          const SizedBox(height: 16),

          // IMPORTES

          Row(
            children: [
              Expanded(
                child: _amountColumn(
                  label: 'Importe autorizado',
                  amount: _money(item.amount),
                  color: dark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _amountColumn(
                  label: 'Importe utilizado',
                  amount: item.evidenceAmount == null
                      ? 'Sin registrar'
                      : _money(item.evidenceAmount!),
                  color: isRegistered ? green : mutedText,
                ),
              ),
            ],
          ),

          // FECHA

          if (item.evidenceDateTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Registrado el '
                      '${_formatDate(item.evidenceDateTime!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // EVIDENCIA

          const SizedBox(height: 16),

          if (hasEvidence)
            InkWell(
              onTap: () => _showEvidence(
                context,
                item,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: softGreen.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: softGreen,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      color: green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evidencia adjunta',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: dark,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Toca para visualizar la fotografía',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: green,
                    ),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  item.evidenceRequired
                      ? Icons.camera_alt_outlined
                      : Icons.image_outlined,
                  size: 17,
                  color: secondaryText,
                ),
                const SizedBox(width: 7),
                Text(
                  item.evidenceRequired
                      ? 'Evidencia fotográfica requerida'
                      : 'Evidencia fotográfica opcional',
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // BOTÓN

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: isRegistered
                  ? null
                  : () => _openForm(
                        context,
                        ref,
                        item,
                      ),
              icon: Icon(
                isRegistered
                    ? Icons.check_circle_outline
                    : Icons.add_circle_outline,
                size: 19,
              ),
              label: Text(
                isRegistered ? 'Viático registrado' : 'Registrar viático',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: softGreen,
                disabledForegroundColor: green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountColumn({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // =========================
  // ESTADO VACÍO
  // =========================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: mutedText,
          ),
          SizedBox(height: 16),
          Text(
            'Sin viáticos asignados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: dark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Todavía no hay conceptos de viáticos '
            'asignados a esta remisión.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // PANTALLA PRINCIPAL
  // =========================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      travelExpenseConceptsProvider(arguments.idSolicitud),
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Viáticos',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar viáticos',
            onPressed: () {
              ref.invalidate(
                travelExpenseConceptsProvider(arguments.idSolicitud),
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: state.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(
              color: green,
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 52,
                    color: secondaryText,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudieron cargar los viáticos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        travelExpenseConceptsProvider(arguments.idSolicitud),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (items) {
          return RefreshIndicator(
            color: green,
            onRefresh: () async {
              ref.invalidate(
                travelExpenseConceptsProvider(arguments.idSolicitud),
              );

              await ref.read(
                travelExpenseConceptsProvider(arguments.idSolicitud).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                28,
              ),
              children: [
                // RESUMEN

                _buildSummary(items),

                const SizedBox(height: 24),

                // ENCABEZADO DE LISTADO

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Conceptos asignados',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: dark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${items.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: green,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  'Registra los importes utilizados '
                  'y adjunta sus comprobantes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),

                const SizedBox(height: 18),

                // LISTADO

                if (items.isEmpty)
                  _buildEmptyState()
                else
                  for (final item in items)
                    _buildExpenseCard(
                      context,
                      ref,
                      item,
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

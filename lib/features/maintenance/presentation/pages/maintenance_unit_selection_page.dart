import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/features/maintenance/presentation/providers/maintenance_units_provider.dart';

import '../../domain/entities/maintenance_unit_assigned.dart';
import '../../domain/entities/maintenance_units_list_entity.dart';

class MaintenanceUnitSelectionPage extends ConsumerStatefulWidget {
  const MaintenanceUnitSelectionPage({
    super.key,
    this.onContinue,
  });

  final void Function(String unitId, String vehicleNumber)? onContinue;

  @override
  ConsumerState<MaintenanceUnitSelectionPage> createState() =>
      _MaintenanceUnitSelectionPageState();
}

class _MaintenanceUnitSelectionPageState
    extends ConsumerState<MaintenanceUnitSelectionPage> {
  static const Color green = Color(0xFF1E7A3C);
  static const Color dark = Color(0xFF101812);
  static const Color background = Color(0xFFF7F8F6);
  static const Color softGreen = Color(0xFFE1F0E3);
  static const Color secondary = Color(0xFF6B6B66);
  static const Color muted = Color(0xFF9A9A94);
  static const Color border = Color(0xFFE0E0DA);

  // ==========================================
  // CONTINUAR AL FORMULARIO
  // ==========================================

  void _continue(
    BuildContext context, {
    required String unitId,
    required String vehicleNumber,
  }) {
    if (widget.onContinue != null) {
      widget.onContinue!(unitId, vehicleNumber);
      return;
    }

    context.push(
      AppRoutes.maintenanceReport,
      extra: {
        'unitId': unitId,
        'vehicleNumber': vehicleNumber,
      },
    );
  }

  // ==========================================
  // ACTUALIZAR DATOS
  // ==========================================

  Future<void> _refresh() async {
    ref.invalidate(assignedUnitProvider);
    ref.invalidate(activeUnitsProvider);

    await Future.wait([
      ref.read(assignedUnitProvider.future),
      ref.read(activeUnitsProvider.future),
    ]);
  }

  // ==========================================
  // SELECCIONAR OTRA UNIDAD
  // ==========================================

  Future<void> _showUnitsBottomSheet(
    BuildContext context,
    List<MaintenanceUnitsListEntity> units,
  ) async {
    String localSearchQuery = '';

    final selected = await showModalBottomSheet<MaintenanceUnitsListEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            final activeUnits = units.where((unit) {
              final isActive = unit.status.trim().toLowerCase() == 'activa';
              if (!isActive) return false;

              if (localSearchQuery.trim().isEmpty) return true;

              final query = localSearchQuery.toLowerCase();
              return unit.vehicleNumber.toLowerCase().contains(query) ||
                  unit.brand.toLowerCase().contains(query) ||
                  unit.plates.toLowerCase().contains(query);
            }).toList();

            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Seleccionar unidad',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: dark,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar unidad...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setStateSheet(() {
                          localSearchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: activeUnits.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No hay unidades activas disponibles.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: secondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: activeUnits.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final unit = activeUnits[index];

                              return Material(
                                color: background,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.pop(
                                      sheetContext,
                                      unit,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: softGreen,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.local_shipping_outlined,
                                            color: green,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Económico ${unit.vehicleNumber}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: dark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                [
                                                  unit.brand,
                                                  unit.plates,
                                                ]
                                                    .where(
                                                      (value) => value
                                                          .trim()
                                                          .isNotEmpty,
                                                    )
                                                    .join(' · '),
                                                style: const TextStyle(
                                                  color: secondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null && context.mounted) {
      _continue(
        context,
        unitId: selected.id,
        vehicleNumber: selected.vehicleNumber,
      );
    }
  }

  // ==========================================
  // TARJETA DE UNIDAD ASIGNADA
  // ==========================================

  Widget _assignedUnitCard(
    BuildContext context,
    MaintenanceUnitAssigned unit,
    AsyncValue<List<MaintenanceUnitsListEntity>> unitsState,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
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
                Icons.verified_outlined,
                color: green,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'UNIDAD ASIGNADA',
                style: TextStyle(
                  color: secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: softGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Número económico',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unit.vehicleNumber,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: border),
          const SizedBox(height: 16),
          _detailRow('Marca', unit.brand),
          const SizedBox(height: 10),
          _detailRow('Placas', unit.plates),
          const SizedBox(height: 10),
          _detailRow('Estado', unit.status),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _continue(
                context,
                unitId: unit.id,
                vehicleNumber: unit.vehicleNumber,
              ),
              icon: const Icon(
                Icons.arrow_forward,
                size: 19,
              ),
              label: const Text(
                'Continuar con esta unidad',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: unitsState.maybeWhen(
                data: (units) => () => _showUnitsBottomSheet(context, units),
                orElse: () => null,
              ),
              icon: const Icon(
                Icons.swap_horiz,
                size: 19,
              ),
              label: Text(
                unitsState.isLoading
                    ? 'Cargando unidades...'
                    : 'Seleccionar otra unidad',
              ),
              style: TextButton.styleFrom(
                foregroundColor: green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIN UNIDAD ASIGNADA
  // ==========================================

  Widget _noAssignedUnitCard(
    BuildContext context,
    AsyncValue<List<MaintenanceUnitsListEntity>> unitsState,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: softGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: green,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sin unidad asignada',
            style: TextStyle(
              color: dark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Actualmente no tienes una unidad asignada. '
            'Selecciona una unidad activa para continuar '
            'con tu reporte de mantenimiento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: unitsState.maybeWhen(
                data: (units) => () => _showUnitsBottomSheet(context, units),
                orElse: () => null,
              ),
              icon: const Icon(
                Icons.list_alt_outlined,
                size: 19,
              ),
              label: Text(
                unitsState.isLoading
                    ? 'Cargando unidades...'
                    : 'Seleccionar unidad',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
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

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              color: secondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'No disponible' : value,
            style: const TextStyle(
              color: dark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ESTADO DE ERROR
  // ==========================================

  Widget _errorCard(
    WidgetRef ref,
    Object error,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: secondary,
            size: 44,
          ),
          const SizedBox(height: 14),
          const Text(
            'No se pudo consultar tu unidad',
            style: TextStyle(
              color: dark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(assignedUnitProvider);
              ref.invalidate(activeUnitsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PANTALLA PRINCIPAL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final assignedState = ref.watch(assignedUnitProvider);
    final unitsState = ref.watch(activeUnitsProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Reporte de mantenimiento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: green,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          children: [
            const Text(
              'Selecciona la unidad',
              style: TextStyle(
                color: dark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Confirma la unidad con la que deseas '
              'generar el reporte de mantenimiento.',
              style: TextStyle(
                color: secondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            assignedState.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: CircularProgressIndicator(
                    color: green,
                  ),
                ),
              ),
              error: (error, _) => _errorCard(ref, error),
              data: (assignedUnit) {
                if (assignedUnit == null) {
                  return _noAssignedUnitCard(
                    context,
                    unitsState,
                  );
                }

                return _assignedUnitCard(
                  context,
                  assignedUnit,
                  unitsState,
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: softGreen.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: green,
                    size: 19,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'La unidad seleccionada se utilizará '
                      'para vincular tu solicitud con el '
                      'activo correspondiente en Fracttal.',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

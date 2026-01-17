import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/containers_map.dart';

class MapaUbicacionesWidget extends StatefulWidget {
  final UbicacionesViewModel vm;
  final String tipoMovimiento;
  final String? movementId;

  // Datos iniciales (pueden venir null)
  final String? areaInicial;
  final String? espacioInicial;
  final String? nivelInicial;

  const MapaUbicacionesWidget({
    Key? key,
    required this.vm,
    required this.tipoMovimiento,
    required this.movementId,
    this.areaInicial,
    this.espacioInicial,
    this.nivelInicial,
  }) : super(key: key);

  @override
  State<MapaUbicacionesWidget> createState() => _MapaUbicacionesWidgetState();
}

class _MapaUbicacionesWidgetState extends State<MapaUbicacionesWidget> {
  late UbicacionesViewModel vm;
  late String tipoMovimientoNormalized;

  @override
  void initState() {
    super.initState();
    vm = widget.vm;
    tipoMovimientoNormalized = _toCanonical(widget.tipoMovimiento ?? '');
    print(
        'Normalized tipoMovimiento: $tipoMovimientoNormalized'); // debe imprimir 'pisocamion' etc
  }

  String _toCanonical(String t) {
    if (t.isEmpty) return '';
    final s =
        t.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '').replaceAll('ó', 'o');

    if (s.contains('reacomodo')) return MovementTypes.reacomodo;
    if (s.contains('pisocamion') ||
        (s.contains('piso') &&
            s.contains('camion') &&
            s.indexOf('piso') < s.indexOf('camion'))) {
      return MovementTypes.pisoCamion;
    }
    if (s.contains('camionpiso') ||
        (s.contains('piso') &&
            s.contains('camion') &&
            s.indexOf('camion') < s.indexOf('piso'))) {
      return MovementTypes.camionPiso;
    }
    return s; // devolver lo que sea si no se detecta; permite fallar con mensaje
  }

  bool get isPisoCamion => tipoMovimientoNormalized == MovementTypes.pisoCamion;
  bool get isCamionPiso => tipoMovimientoNormalized == MovementTypes.camionPiso;

  @override
  Widget build(BuildContext context) {
    final areaInicial = widget.areaInicial;
    final espacioInicial = widget.espacioInicial;
    final nivelInicial = widget.nivelInicial;

    // Mensaje informativo si es Piso -> Camión
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          if (isPisoCamion)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    "📦 Movimiento Piso → Camión",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    areaInicial != null &&
                            espacioInicial != null &&
                            nivelInicial != null
                        ? "Ubicación origen: Área $areaInicial – Espacio $espacioInicial – Nivel $nivelInicial"
                        : "Ubicación origen: No disponible",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          Expanded(child: _buildMapa(context)),

          // Botón confirmar solo para Piso -> Camión
          if (isPisoCamion)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: () async {
                  // Validaciones
                  if (widget.areaInicial == null ||
                      widget.espacioInicial == null ||
                      widget.nivelInicial == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('No se encontró la ubicación origen.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final movementVm =
                      Provider.of<ContainerMovementListViewModel>(context,
                          listen: false);
                  final serie = movementVm.selectedContainerNumber;

                  if (serie == null || serie.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              const Text('Número de contenedor no disponible.'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Construir confirm dialog con área/espacio/nivel
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmar movimiento'),
                      content: Text(
                        '¿Confirma que movió el contenedor $serie '
                        'del área ${widget.areaInicial} – espacio ${widget.espacioInicial} – nivel ${widget.nivelInicial} '
                        'al camión?',
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí, mover')),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  // Ejecutar movimiento usando la API / viewmodel
                  await vm.ejecutarMovimiento(
                    context: context,
                    tipoMovimiento: "piso-camion",
                    serieAsignada: serie,
                    area: areaInicial!,
                    espacio: espacioInicial!,
                    nivel: nivelInicial!,
                    movementId: widget.movementId,
                  );
                },
                child: const Text('Confirmar Movimiento Piso → Camión',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapa(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (vm.getAreas().contains("A"))
            _buildArea(context, "A", grande: true),
          const SizedBox(width: 50),
          if (vm.getAreas().contains("B"))
            _buildArea(context, "B", grande: false),
          const SizedBox(width: 30),
          if (vm.getAreas().contains("C"))
            _buildArea(context, "C", grande: false),
          const SizedBox(width: 50),
          if (vm.getAreas().contains("D"))
            _buildArea(context, "D", grande: true),
        ],
      ),
    );
  }

  final double espacioSize = 100; // ancho del botón
  final double spacing = 8; // separación del grid
  final double paddingArea = 24;

  double calcularAnchoArea(int columnas) {
    return (columnas * espacioSize) + ((columnas - 1) * spacing) + paddingArea;
  }

  double alturaArea(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.75;
  }

  Widget _buildArea(BuildContext context, String area, {required bool grande}) {
    final espacios = vm
        .getEspaciosPorArea(area)
        .where((e) => e.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => int.tryParse(a)?.compareTo(int.tryParse(b) ?? 0) ?? 0);

    final crossAxisCount = (area == "A" || area == "D") ? 3 : 6;

    final width = calcularAnchoArea(crossAxisCount);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),

        // ✅ MISMA ALTURA PARA TODAS
        child: SizedBox(
          height: alturaArea(context),
          child: Column(
            children: [
              Text("Área $area", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),

              // ✅ GRID CON SCROLL INTERNO
              Flexible(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  children: espacios
                      .map((e) => _buildEspacioButton(context, area, e, grande))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEspacioButton(
      BuildContext context, String area, String espacio, bool grande) {
    final niveles = vm.getUbicacionesPorAreaEspacioYNivel(area, espacio);

    // Contar cuántos niveles están ocupados
    final ocupados = niveles
        .where((u) => u.numberSerie != null && u.numberSerie!.trim().isNotEmpty)
        .length;
    final disponibles = niveles.length - ocupados;

    // Selección de color según ocupación (tu lógica original)
    Color color;
    if (ocupados == 0) {
      color = Colors.blue;
    } else if (ocupados == 1) {
      color = Colors.green;
    } else if (ocupados == 2) {
      color = Colors.yellow.shade700;
    } else {
      color = Colors.red;
    }

    // ¿Esta celda es la ORIGEN (solo relevante para Piso->Camión)?
    final bool esOrigen = isPisoCamion &&
        widget.areaInicial != null &&
        widget.espacioInicial != null &&
        widget.areaInicial == area &&
        widget.espacioInicial == espacio;

    return GestureDetector(
      onTap: () {
        // Si es movimiento Piso->Camión, NO queremos que el usuario abra el modal:
        if (isPisoCamion) {
          // Opcional: mostrar un tip
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.areaInicial != null
                  ? 'Contenedor en Área ${widget.areaInicial} - Espacio ${widget.espacioInicial}.'
                  : 'Ubicación no disponible.'),
              duration: const Duration(milliseconds: 900),
            ),
          );
          return;
        }
        _showNivelesModal(context, area, espacio);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: grande ? 60 : 48,
        height: grande ? 75 : 62,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: esOrigen ? Colors.green : Colors.black26,
              width: esOrigen ? 4 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$area-$espacio",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: grande ? 13 : 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Niveles disponibles (tu texto)
            Text(
              "Niveles Disponibles: $disponibles",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: grande ? 10 : 9, color: Colors.black),
            ),
            // Si es origen, mostrar pequeño indicador de nivel exacto
            if (esOrigen && !isPisoCamion && widget.nivelInicial != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF2962FF), // azul fuerte
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Nivel ${widget.nivelInicial}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MODAL DE NIVELES (parte muy similar a la tuya, con resaltado de nivel origen)
  // ==========================================================
  void _showNivelesModal(BuildContext context, String area, String espacio) {
    final niveles = vm
        .getNivelesPorEspacio(area, espacio)
        .where((n) => n != null && n.toString().trim().isNotEmpty)
        .toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final nivelesVisual = niveles.reversed.toList();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Niveles",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: Dialog(
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 120),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cerrar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 26),
                          ),
                        ],
                      ),

                      Text(
                        "Niveles – Área $area / Espacio $espacio",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: nivelesVisual.length,
                          itemBuilder: (_, index) {
                            final nivel = nivelesVisual[index];
                            final ubic = vm.getUbicacion(area, espacio, nivel);

                            Color c = Colors.grey;
                            if (ubic?.color == "green") c = Colors.green;
                            if (ubic?.color == "red") c = Colors.red;
                            if (ubic?.color == "yellow") c = Colors.yellow;

                            // ¿Es el nivel ORIGEN del movimiento (solo para Piso->Camión)?
                            final esNivelOrigen = isPisoCamion &&
                                widget.areaInicial != null &&
                                widget.espacioInicial != null &&
                                widget.nivelInicial != null &&
                                widget.areaInicial == area &&
                                widget.espacioInicial == espacio &&
                                widget.nivelInicial == nivel;

                            final bool disponible = ubic?.numberSerie == null ||
                                ubic!.numberSerie!.isEmpty;

                            return GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);

                                // ============================================================
                                // 1) PISO → CAMIÓN
                                // ============================================================
                                if (isPisoCamion) {
                                  final error = vm.seleccionarPuntoPisoCamion(
                                      area, espacio, nivel);
                                  if (error != null) {
                                    mostrarError(context, error);
                                    return;
                                  }

                                  final origen = vm.origen;
                                  if (origen == null) {
                                    mostrarError(
                                        context, "No se encontró origen.");
                                    return;
                                  }

                                  print(
                                      'numero de serie seleccionado en piso camion: ${origen.numeroSerie}');

                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirmar movimiento"),
                                      content: Text(
                                        "¿Confirma que movió el contenedor ${origen.numeroSerie} "
                                        "del área ${origen.area} – espacio ${origen.espacio} – nivel ${origen.nivel} "
                                        "al camión?",
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancelar")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Mover")),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    await vm.ejecutarMovimiento(
                                      context: context,
                                      tipoMovimiento: "piso-camion",
                                      serieAsignada: origen.numeroSerie!,
                                      movementId: widget.movementId,
                                    );
                                  }

                                  return;
                                }

                                if (isCamionPiso) {
                                  final movementVm = Provider.of<
                                          ContainerMovementListViewModel>(
                                      context,
                                      listen: false);
                                  final serie =
                                      movementVm.selectedContainerNumber;

                                  final error = vm.seleccionarPuntoCamionPiso(
                                      area, espacio, nivel);
                                  if (error != null) {
                                    mostrarError(context, error);
                                    return;
                                  }

                                  // ============================================================
                                  // VALIDACIÓN DE NIVELES – CAMIÓN → PISO
                                  // ============================================================
                                  final niveles = vm
                                      .getNivelesPorEspacio(area, espacio)
                                      .where((n) =>
                                          n != null &&
                                          n.toString().trim().isNotEmpty)
                                      .map((n) => int.parse(n.toString()))
                                      .toList()
                                    ..sort();

                                  // convertir el nivel seleccionado a int
                                  final nivelInt = int.parse(nivel.toString());

                                  bool inferioresOcupados = true;

                                  for (final n in niveles) {
                                    if (n < nivelInt) {
                                      final u = vm.getUbicacion(
                                          area, espacio, n.toString());
                                      final vacio = u == null ||
                                          u.numberSerie == null ||
                                          u.numberSerie!.isEmpty;

                                      if (vacio) {
                                        inferioresOcupados = false;
                                        break;
                                      }
                                    }
                                  }

                                  if (!inferioresOcupados) {
                                    mostrarError(
                                      context,
                                      "Para colocar un contenedor en el nivel $nivel, "
                                      "todos los niveles inferiores deben estar ocupados.",
                                    );
                                    return;
                                  }
                                  // ============================================================

                                  final destino = vm.destino;
                                  if (destino == null) {
                                    mostrarError(context,
                                        "Error: destino no está seleccionado.");
                                    return;
                                  }

                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirmar movimiento"),
                                      content: Text(
                                        "¿Confirmas bajar el contenedor $serie al área "
                                        "${destino.area} – espacio ${destino.espacio} – nivel ${destino.nivel}?",
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancelar")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Mover")),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    await vm.ejecutarMovimiento(
                                      context: context,
                                      tipoMovimiento: "camion-piso",
                                      serieAsignada: serie,
                                      movementId: widget.movementId,
                                    );
                                  }

                                  return;
                                }

                                // ============================================================
                                // 3) REACOMODO
                                // ============================================================
                                final error = vm.seleccionarPuntoReacomodo(
                                    area, espacio, nivel);
                                if (error != null) {
                                  mostrarError(context, error);
                                  return;
                                }

                                // ORIGEN SELECCIONADO
                                if (vm.origen != null && vm.destino == null) {
                                  mostrarOk(context,
                                      "Contenedor con numero de serie ${vm.origen!.numeroSerie} del area, espacio y nivel ${vm.origen!.area}-${vm.origen!.espacio}-${vm.origen!.nivel}");
                                  return;
                                }

                                // DESTINO SELECCIONADO → CONFIRMAR
                                if (vm.origen != null && vm.destino != null) {
                                  final origen = vm.origen!;
                                  final destino = vm.destino!;
                                  final serie = origen.numeroSerie!;

                                  // --- VALIDACIÓN DE NIVELES (igual que camión–piso) ---
                                  final nivelDestinoInt =
                                      int.parse(destino.nivel.toString());

                                  final niveles = vm
                                      .getNivelesPorEspacio(
                                          destino.area, destino.espacio)
                                      .where((n) =>
                                          n != null &&
                                          n.toString().trim().isNotEmpty)
                                      .map((n) => int.parse(n.toString()))
                                      .toList()
                                    ..sort();

                                  bool inferioresOcupados = true;

                                  for (final n in niveles) {
                                    if (n < nivelDestinoInt) {
                                      final u = vm.getUbicacion(destino.area,
                                          destino.espacio, n.toString());
                                      final vacio = u == null ||
                                          u.numberSerie == null ||
                                          u.numberSerie!.isEmpty;

                                      if (vacio) {
                                        inferioresOcupados = false;
                                        break;
                                      }
                                    }
                                  }

                                  if (!inferioresOcupados) {
                                    mostrarError(
                                      context,
                                      "No puede asignar al nivel ${destino.nivel} porque hay niveles inferiores vacíos.",
                                    );
                                    return;
                                  }

                                  // --- CONFIRMAR ---
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirmar reacomodo"),
                                      content: Text(
                                        "¿Confirma mover el contenedor $serie "
                                        "del Área ${origen.area}-${origen.espacio}-${origen.nivel} "
                                        "al Área ${destino.area}-${destino.espacio}-${destino.nivel}?",
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancelar")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Mover")),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    await vm.ejecutarMovimiento(
                                      context: context,
                                      tipoMovimiento: "reacomodo",
                                      serieAsignada: serie,
                                      movementId: widget.movementId,
                                    );
                                  }

                                  return;
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: disponible
                                      ? Colors.green // Disponible = verde
                                      : (esNivelOrigen ? Colors.blue : c),
                                  borderRadius: BorderRadius.circular(12),
                                  border: esNivelOrigen
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        nivel,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        disponible
                                            ? "Disponible"
                                            : ubic!.numberSerie!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void mostrarError(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red),
  );
}

void mostrarOk(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.green),
  );
}

class _EstadoColor extends StatelessWidget {
  final Color color;
  final String texto;

  const _EstadoColor({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

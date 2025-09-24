import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class TruckFloorScreen extends StatefulWidget {
  final String? initialArea;
  final String? initialEspacio;
  final String? initialNivel;
  final String? containerNumber;
  final int? movementId;

  const TruckFloorScreen({
    super.key,
    required this.initialArea,
    required this.initialEspacio,
    required this.initialNivel,
    this.containerNumber,
    this.movementId,
  });

  @override
  State<TruckFloorScreen> createState() => _TruckFloorScreenState();
}

class _TruckFloorScreenState extends State<TruckFloorScreen> {
  final UbicacionesViewModel vm = UbicacionesViewModel();
  late String? area;
  late String? espacio;
  late String? nivel;
  late String? containerNumber;

  String? destinoArea;
  String? destinoEspacio;
  String? destinoNivel;

  String? error;
  bool isLoading = true;
  String? currentSiteId;

  Future<void> _loadUbicaciones() async {
    try {
      final vm = Provider.of<UbicacionesViewModel>(context, listen: false);
      await vm.cargarUbicacionesDesdeApi();
    } catch (e) {
      error = 'Error al cargar ubicaciones';
    } finally {
      if (!mounted) return; // ✅ Evita el error si el widget ya no existe
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    area = widget.initialArea;
    espacio = widget.initialEspacio;
    nivel = widget.initialNivel;
    containerNumber = widget.containerNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        print('NUMERO DE SITE ID: ${session.siteId}');
        setState(() {
          error = "No se encontró un site_id válido. Inicie sesión nuevamente.";
          isLoading = false;
        });
        return;
      }

      // ✅ Guardamos el siteId en el estado de la pantalla
      setState(() {
        currentSiteId = session.siteId;
      });

      // ✅ Ahora sí cargamos ubicaciones
      await _loadUbicaciones();
    });
  }

  // 🔹 Método para mostrar el modal con los espacios

  // 🔹 Método principal que arma el mapa del camión
  Widget buildCamionPisoMap() {
    return Consumer<UbicacionesViewModel>(
      builder: (context, vm, _) {
        final String? areaInicial = widget.initialArea;
        //final String? espacioInicial = widget.initialEspacio;
        //final String? nivelInicial = widget.initialNivel;

        final areas = vm.getAreas();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona un área para colocar el contenedor:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              /// 🔹 Áreas en cuadrícula adaptativa
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: areas.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final area = areas[index];
                  final bool esAreaSeleccionada = area == areaInicial;

                  return GestureDetector(
                    onTap: () {
                      if (vm.getEspaciosPorArea(area).isNotEmpty) {
                        _mostrarModalEspacios(context, vm, area);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Cargando espacios, por favor espera..."),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: esAreaSeleccionada
                            ? Colors.green.shade200
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esAreaSeleccionada
                              ? Colors.green
                              : Colors.green.shade300,
                          width: esAreaSeleccionada ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Área $area',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: esAreaSeleccionada
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: esAreaSeleccionada
                                ? Colors.green.shade900
                                : Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarModalEspacios(
      BuildContext context, UbicacionesViewModel vm, String area) {
    final espacios = vm.getEspaciosPorArea(area);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Área: $area',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text('Selecciona un espacio:'),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.extent(
                    maxCrossAxisExtent: 140,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: espacios.map((espacio) {
                      return GestureDetector(
                        onTap: () {
                          _mostrarModalNiveles(context, vm, area, espacio);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Espacio $espacio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalNiveles(BuildContext context, UbicacionesViewModel vm,
      String area, String espacio) {
    final niveles = vm.getNivelesPorEspacioCamionPiso(area, espacio);
    niveles.sort((a, b) => b.compareTo(a));
    final ubicaciones = vm.getUbicacionesPorAreaEspacioYNivel(area, espacio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 450, maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveles disponibles para: $espacio',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: niveles.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay niveles disponibles.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: niveles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final nivel = niveles[index];
                            final ocupado = vm.nivelEstaOcupadoCamionPiso(
                                area, espacio, nivel);
                            Ubicacion? ubicacion;
                            try {
                              ubicacion = ubicaciones
                                  .firstWhere((u) => u.nivel == nivel);
                            } catch (_) {
                              ubicacion = null;
                            }

                            Color bgColor = ocupado
                                ? Colors.red.shade100
                                : Colors.green.shade100;
                            Color textColor = ocupado
                                ? Colors.red.shade900
                                : Colors.green.shade800;

                            return GestureDetector(
                              onTap: ocupado
                                  ? null
                                  : () {
                                      destinoArea = area;
                                      destinoEspacio = espacio;
                                      destinoNivel = nivel;

                                      final _id = ubicacion?.id;
                                      _showConfirmationTruckFloor(
                                          context,
                                          area,
                                          espacio,
                                          nivel,
                                          ocupado,
                                          _id!,
                                          currentSiteId!);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Seleccionado: $area - $espacio - $nivel',
                                          ),
                                        ),
                                      );
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ocupado
                                        ? Colors.red.shade300
                                        : Colors.green.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nivel $nivel',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    Icon(
                                      ocupado
                                          ? Icons.lock
                                          : Icons.check_circle_outline,
                                      color: ocupado
                                          ? Colors.red.shade400
                                          : Colors.green.shade600,
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
        );
      },
    );
  }

  void _showConfirmationTruckFloor(
    BuildContext context,
    String area,
    String espacio,
    String nivel,
    bool ocupado,
    String id,
    String currentSiteId,
  ) {
    final rootContext = context; // Guarda el contexto válido

    showDialog(
      context: rootContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar selección'),
          content: Text(
            '¿Confirmas la ubicación?\n\nÁrea: $area\nEspacio: $espacio\nNivel: $nivel'
            '${ocupado ? "\n\n⚠️ Este nivel está ocupado." : ""}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Cerrar el diálogo de confirmación
                Navigator.pop(dialogContext);

                // Mostrar modal de "procesando"
                showDialog(
                  context: rootContext,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Expanded(child: Text("Registrando movimiento...")),
                      ],
                    ),
                  ),
                );

                final vm = Provider.of<UbicacionesViewModel>(
                  rootContext,
                  listen: false,
                );

                // Guardar destino
                destinoArea = area;
                destinoEspacio = espacio;
                destinoNivel = nivel;

                bool exito = false;

                try {
                  await vm.registrarMovimientoCamionPiso(
                    destinoId: id,
                    movementId: widget.movementId.toString(),
                    numberSerie: widget.containerNumber!,
                    siteId: currentSiteId,
                  );
                  exito = true;
                } catch (e) {
                  exito = false;
                }

                // Cerrar el modal de "procesando"
                if (Navigator.canPop(rootContext)) {
                  Navigator.pop(rootContext);
                }

                // Mostrar notificación
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          exito ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            exito
                                ? 'Movimiento registrado en: $area - $espacio - $nivel'
                                : '❌ Error al registrar el movimiento.',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: exito ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );

                HapticFeedback.mediumImpact();

                await Future.delayed(const Duration(seconds: 2));

                // Cerrar hasta 3 pantallas/modales previos
                int pops = 0;
                while (Navigator.canPop(rootContext) && pops < 2) {
                  Navigator.pop(rootContext);
                  pops++;
                }

                // Si aún se puede cerrar una más (la principal), devuélvela con resultado
                if (Navigator.canPop(rootContext)) {
                  Navigator.pop(rootContext, 'recargar');
                } else {
                  // Si no fue posible, mostrar advertencia
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '⚠️ No se pudieron cerrar todas las ventanas correctamente.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimiento Camión - Piso',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: buildCamionPisoMap(),
    );
  }
}

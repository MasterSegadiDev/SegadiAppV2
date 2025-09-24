import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class FloorTruckScreen extends StatefulWidget {
  final String? initialArea;
  final String? initialEspacio;
  final String? initialNivel;
  final String? containerNumber;
  final int? movementId;

  const FloorTruckScreen({
    super.key,
    required this.initialArea,
    required this.initialEspacio,
    required this.initialNivel,
    required this.containerNumber,
    required this.movementId,
  });

  @override
  State<FloorTruckScreen> createState() => _FloorTruckScreenState();
}

class _FloorTruckScreenState extends State<FloorTruckScreen> {
  final UbicacionesViewModel vm = UbicacionesViewModel();
  String? error;
  bool isLoading = true;
  String? currentSiteId;

  String? destinoArea;
  String? destinoEspacio;
  String? destinoNivel;

  @override
  void initState() {
    super.initState();
    // area = widget.initialArea;
    // espacio = widget.initialEspacio;
    // nivel = widget.initialNivel;
    // containerNumber = widget.containerNumber;

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
  Widget buildPisoCamionMap() {
    return Consumer<UbicacionesViewModel>(
      builder: (context, vm, _) {
        final String? areaSeleccionada = widget.initialArea;
        final String? espacioSeleccionado = widget.initialEspacio;
        final String? nivelSeleccionado = widget.initialNivel;

        // ✅ Validar si falta información inicial
        if (areaSeleccionada == null ||
            espacioSeleccionado == null ||
            nivelSeleccionado == null) {
          return const Center(
            child: Text(
              'Ubicación inicial incompleta.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final areas = vm.getAreas();

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación actual para seleccionar el contenedor:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Área: $areaSeleccionada | Espacio: $espacioSeleccionado | Nivel: $nivelSeleccionado',
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 24),

                  /// 🔹 Grid flexible de áreas
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: areas.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      final bool esAreaSeleccionada = area == areaSeleccionada;

                      return GestureDetector(
                        onTap: () {
                          // ✅ Solo mostramos la modal si ya hay datos cargados
                          if (vm.getEspaciosPorArea(area).isNotEmpty) {
                            _mostrarModalEspaciosPisoCamion(
                              context,
                              vm,
                              area,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Cargando espacios, por favor espera...",
                                ),
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
      },
    );
  }

  /// 🔹 Método para mostrar el modal de espacios
  void _mostrarModalEspaciosPisoCamion(
      BuildContext context, UbicacionesViewModel vm, String area) {
    final espacios = vm.getEspaciosPorArea(area);
    espacios.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final String? espacioSeleccionado = widget.initialEspacio;
    final String? areaSeleccionada = widget.initialArea;

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
                      final bool esEspacioSeleccionado =
                          espacio == espacioSeleccionado &&
                              area == areaSeleccionada;

                      return GestureDetector(
                        onTap: () {
                          _mostrarModalNivelesPisoCamion(
                              context, vm, area, espacio);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: esEspacioSeleccionado
                                ? Colors.green.shade200
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: esEspacioSeleccionado
                                  ? Colors.green
                                  : Colors.green.shade300,
                              width: esEspacioSeleccionado ? 3 : 1,
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
                              fontWeight: esEspacioSeleccionado
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: esEspacioSeleccionado
                                  ? Colors.green.shade900
                                  : Colors.blueGrey.shade800,
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

  void _mostrarModalNivelesPisoCamion(
    BuildContext context,
    UbicacionesViewModel vm,
    String area,
    String espacio,
  ) {
    final niveles = vm.getUbicacionesPorAreaEspacioYNivel(area, espacio);
    final nivelesOrdenados = List.of(niveles)
      ..sort((a, b) => b.nivel.compareTo(a.nivel));

    final String? nivelSeleccionado = widget.initialNivel;
    final String? areaSeleccionada = widget.initialArea;
    final String? espacioSeleccionado = widget.initialEspacio;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 420,
            width: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              // color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Encabezado mejorado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveles de: $espacio',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),

                // 🔹 Lista de niveles con mejor diseño
                Expanded(
                  child: ListView.separated(
                    itemCount: nivelesOrdenados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ubicacion = nivelesOrdenados[index];
                      final ocupado = vm.nivelEstaOcupado(
                        ubicacion.area,
                        ubicacion.espacio,
                        ubicacion.nivel,
                      );

                      final bool esNivelSeleccionado =
                          ubicacion.nivel == nivelSeleccionado &&
                              ubicacion.area == areaSeleccionada &&
                              ubicacion.espacio == espacioSeleccionado;

                      final color = ubicacion.color;

                      Color tileColor;
                      if (esNivelSeleccionado) {
                        tileColor = Colors.orange.shade200;
                      } else if (ubicacion.estado == 'Used') {
                        tileColor = colorMap[color] ?? Colors.grey;
                      } else if (ubicacion.estado == 'Free') {
                        tileColor = colorMap[color] ?? Colors.grey;
                      } else {
                        tileColor = Colors.grey.shade200;
                      }

                      return GestureDetector(
                        onTap: esNivelSeleccionado
                            ? () {
                                _mostrarConfirmacionSeleccion(
                                  context,
                                  ubicacion.area,
                                  ubicacion.espacio,
                                  ubicacion.nivel,
                                  ocupado,
                                  ubicacion.id,
                                  currentSiteId!,
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '⚠️ Solo puedes seleccionar el nivel indicado para este movimiento.',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: esNivelSeleccionado
                                  ? Colors.green.shade600
                                  : Colors.grey.shade300,
                              width: esNivelSeleccionado ? 2.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 🔹 Info del nivel
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nivel ${ubicacion.nivel}',
                                    style: TextStyle(
                                      fontWeight: esNivelSeleccionado
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (esNivelSeleccionado)
                                    Text(
                                      'Contenedor: ${widget.containerNumber}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                ],
                              ),

                              // 🔹 Estado con íconos claros
                              if (ocupado && esNivelSeleccionado)
                                const Icon(Icons.check_circle,
                                    color: Colors.deepOrange, size: 24)
                              else if (ocupado)
                                const Icon(Icons.block,
                                    color: Colors.red, size: 24)
                              else
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.green, size: 24),
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

  void _mostrarConfirmacionSeleccion(
    BuildContext context,
    String area,
    String espacio,
    String nivel,
    bool ocupado,
    String id,
    String _currentSiteId,
  ) {
    final rootContext = context;

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
                // Cerrar el modal de confirmación
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

                destinoArea = area;

                bool exito = false;

                try {
                  // Aquí llamas tu método real
                  await vm.registrarMovimientoPisoCamion(
                    destinoId: id,
                    movementId: widget.movementId.toString(),
                    numberSerie: widget.containerNumber!,
                    siteId: _currentSiteId,
                  );
                  exito = true;
                } catch (e) {
                  exito = false;
                }

                // Cerrar modal de "procesando"
                if (Navigator.canPop(rootContext)) {
                  Navigator.pop(rootContext);
                }

                // Mostrar resultado
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
                                ? 'Movimiento registrado con éxito en: $area - $espacio - $nivel'
                                : '❌ Ocurrió un error al registrar el movimiento.',
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

                // Cerrar todos los posibles modales abiertos
                int popsRealizados = 0;
                while (Navigator.canPop(rootContext) && popsRealizados < 2) {
                  Navigator.pop(rootContext);
                  popsRealizados++;
                }

                // Notificar si fue exitoso y devolver resultado a la pantalla anterior
                if (exito) {
                  if (Navigator.canPop(rootContext)) {
                    Navigator.pop(context, 'recargar');
                  }
                } else {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '⚠️ No se pudo completar el registro. Intenta nuevamente.',
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
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

  bool nivelEstaOcupado(String area, String espacio, String nivel) {
    return int.tryParse(nivel) != null && int.parse(nivel) % 2 == 0;
  }

  final Map<String, Color> colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'black': Colors.black,
    'white': Colors.white,
    'grey': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimiento Piso - Camión',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: buildPisoCamionMap(),
    );
  }
}

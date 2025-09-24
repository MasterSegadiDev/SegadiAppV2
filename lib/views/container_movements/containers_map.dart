import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/widgets/widgetContainerRearrangement.dart';
import 'package:segadi/views/container_movements/widgets/widgetFloorTruck.dart';
import 'package:segadi/views/container_movements/widgets/widgetTruckFloor.dart';
import 'package:segadi/views/container_movements/widgets/widgetWeightContainer.dart';

class ContainersMapScreen extends StatefulWidget {
  final String? status;
  final int? movementId;
  final String? initialArea;
  final String? initialEspacio;
  final String? initialNivel;
  final String movementType;
  final String? containerNumber;

  const ContainersMapScreen({
    super.key,
    this.status,
    this.movementId,
    this.initialArea,
    this.initialEspacio,
    this.initialNivel,
    required this.movementType,
    this.containerNumber,
    required String siteId,
  });

  @override
  State<ContainersMapScreen> createState() => _ContainersMapScreenState();
}

class _ContainersMapScreenState extends State<ContainersMapScreen> {
  final UbicacionesViewModel vm = UbicacionesViewModel();
  bool _isLoading = true;
  String? _error;

  String? _origenArea;
  String? _origenEspacio;
  String? _origenNivel;
  String? _numeroSerieOrigen;

// Para guardar la selección de destino
  String? _destinoArea;
  String? _destinoEspacio;
  String? _destinoNivel;

  var _numeroSerieController = TextEditingController();
  final TextEditingController _pesoBrutoController = TextEditingController();
  final _nombreImagenPesoController = TextEditingController();

  String? _currentSiteId;

  @override
  void initState() {
    super.initState();

    vm.clearSelectedImage();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = UserSession();
      await session.loadFromPrefs();

      if (session.siteId == null || session.siteId!.isEmpty) {
        print('NUMERO DE SITE ID: ${session.siteId}');
        setState(() {
          _error =
              "No se encontró un site_id válido. Inicie sesión nuevamente.";
          _isLoading = false;
        });
        return;
      }

      // ✅ Guardamos el siteId en el estado de la pantalla
      setState(() {
        _currentSiteId = session.siteId;
      });

      // ✅ Ahora sí cargamos ubicaciones
      await _loadUbicaciones();
    });

    _numeroSerieController = TextEditingController(
      text: widget.containerNumber ?? '',
    );
  }

  Future<void> _loadUbicaciones() async {
    try {
      final vm = Provider.of<UbicacionesViewModel>(context, listen: false);
      await vm.cargarUbicacionesDesdeApi();
    } catch (e) {
      _error = 'Error al cargar ubicaciones';
    } finally {
      if (!mounted) return; // ✅ Evita el error si el widget ya no existe
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UbicacionesViewModel>(context);

    // Mientras carga la información inicial
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si hay error, mostramos mensaje
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2C522A),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    // Ahora usamos un switch para mostrar la pantalla correcta
    switch (widget.movementType) {
      case 'Piso-Camion':
        return FloorTruckScreen(
          initialArea: widget.initialArea,
          initialEspacio: widget.initialEspacio,
          initialNivel: widget.initialNivel,
          containerNumber: widget.containerNumber,
          movementId: widget.movementId,
        );
      // return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Movimiento Piso - Camión',
      //         style: TextStyle(color: Colors.white)),
      //     iconTheme: const IconThemeData(color: Colors.white),
      //     backgroundColor: const Color(0xFF2C522A),
      //   ),
      //   body: Padding(
      //     padding: const EdgeInsets.all(12.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const SizedBox(height: 8),
      //         Expanded(child: _buildPisoCamionMap()),
      //       ],
      //     ),
      //   ),
      // );

      case 'Camion-Piso':
        return TruckFloorScreen(
          initialArea: widget.initialArea,
          initialEspacio: widget.initialEspacio,
          initialNivel: widget.initialNivel,
          movementId: widget.movementId,
          containerNumber: widget.containerNumber,
        );
      // return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Movimiento Camión - Piso',
      //         style: TextStyle(color: Colors.white)),
      //     iconTheme: const IconThemeData(color: Colors.white),
      //     backgroundColor: const Color(0xFF2C522A),
      //   ),
      //   body: Padding(
      //     padding: const EdgeInsets.all(12.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const SizedBox(height: 8),
      //         Expanded(child: buildCamionPisoMap()),
      //       ],
      //     ),
      //   ),
      // );

      case 'Reacomodo':
        return ContainerRearrangementScreen();
      // return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Reacomodo de contenedores',
      //         style: TextStyle(color: Colors.white)),
      //     iconTheme: const IconThemeData(color: Colors.white),
      //     backgroundColor: const Color(0xFF2C522A),
      //   ),
      //   body: Padding(
      //     padding: const EdgeInsets.all(12.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const Text(
      //           'Seleccione ubicación de origen:',
      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //         ),
      //         const SizedBox(height: 8),
      //         Expanded(child: buildAreaMapReacomodo(vm, isOrigen: true)),
      //         const Divider(height: 32),
      //         const Text(
      //           'Seleccione ubicación de destino:',
      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //         ),
      //         const SizedBox(height: 8),
      //         Expanded(child: buildAreaMapReacomodo(vm, isOrigen: false)),
      //       ],
      //     ),
      //   ),
      // );

      case 'Pesaje':
        // Aquí usamos tu formulario actual de pesaje
        return PesajeFormScreen();

      default:
        return const Scaffold(
          body: Center(
            child: Text(
              'Tipo de movimiento no soportado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  Widget buildPisoCamionMap() {
    return Consumer<UbicacionesViewModel>(
      builder: (context, vm, _) {
        final String? areaSeleccionada = widget.initialArea;
        final String? espacioSeleccionado = widget.initialEspacio;
        final String? nivelSeleccionado = widget.initialNivel;

        // if (areaSeleccionada == null ||
        //     espacioSeleccionado == null ||
        //     nivelSeleccionado == null) {
        //   return const Center(child: Text('Ubicación inicial incompleta.'));
        // }

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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Área: ${areaSeleccionada ?? " "}   Espacio: ${espacioSeleccionado ?? " "}   Nivel: ${nivelSeleccionado ?? " "}',
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 24),

                  /// Grid flexible
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
                        onTap: () =>
                            _mostrarModalEspaciosPisoCamion(context, vm, area),
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

  Widget buildAreaMapReacomodo(UbicacionesViewModel vm,
      {required bool isOrigen}) {
    return Consumer<UbicacionesViewModel>(
      builder: (context, vm, _) {
        final areas = vm.getAreas();

        return ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, areaIndex) {
            final area = areas[areaIndex];
            final espacios = vm.getEspaciosPorArea(area);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Área $area',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  children: espacios.map((espacio) {
                    final ubicaciones = vm.getUbicacionesPorAreaEspacioYNivel(
                        area, espacio, null);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Espacio $espacio',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: ubicaciones.map((ubicacion) {
                              final nivel = ubicacion.nivel;
                              final ocupado = ubicacion.estado != 'Free';
                              final numeroSerie =
                                  ubicacion.numberSerie ?? 'N/A';

                              final isSeleccionada = isOrigen
                                  ? (_origenArea == area &&
                                      _origenEspacio == espacio &&
                                      _origenNivel == nivel)
                                  : (_destinoArea == area &&
                                      _destinoEspacio == espacio &&
                                      _destinoNivel == nivel);

                              final esSeleccionValida = isOrigen ||
                                  (!ocupado); // solo libres en destino

                              return SizedBox(
                                width: 160,
                                height: 80,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSeleccionada
                                        ? Colors.grey.shade300
                                        : ocupado
                                            ? Colors.red.shade300
                                            : Colors.green.shade400,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  onPressed: esSeleccionValida
                                      ? () => _onNivelSeleccionado(
                                            area: area,
                                            espacio: espacio,
                                            nivel: nivel,
                                            isOrigen: isOrigen,
                                            numeroSerie: numeroSerie,
                                          )
                                      : null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        nivel,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        numeroSerie,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(thickness: 1),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onNivelSeleccionado({
    required String area,
    required String espacio,
    required String nivel,
    required bool isOrigen,
    required String numeroSerie,
  }) {
    setState(() {
      if (isOrigen) {
        _origenArea = area;
        _origenEspacio = espacio;
        _origenNivel = nivel;
        _numeroSerieOrigen = numeroSerie;
      } else {
        _destinoArea = area;
        _destinoEspacio = espacio;
        _destinoNivel = nivel;
      }
    });

    final tipo = isOrigen ? 'Origen' : 'Destino';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '$tipo seleccionado: $area - $espacio - $nivel - $_numeroSerieOrigen'),
        backgroundColor: Colors.green,
      ),
    );

    // Si ambos están seleccionados, pedimos confirmación
    if (_origenArea != null &&
        _origenEspacio != null &&
        _origenNivel != null &&
        _destinoArea != null &&
        _destinoEspacio != null &&
        _destinoNivel != null &&
        _numeroSerieOrigen != null &&
        _numeroSerieOrigen!.isNotEmpty) {
      _mostrarDialogoConfirmacion();
    }
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Reacomodo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Origen: $_origenArea - $_origenEspacio - $_origenNivel'),
              Text(
                  'Numero de serie contenedor: ${_numeroSerieOrigen}'), // <-- Aquí lo agregas
              const SizedBox(height: 8),
              Text(
                  'Destino: $_destinoArea - $_destinoEspacio - $_destinoNivel'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _registrarReacomodo();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarReacomodo() async {
    final vm = Provider.of<UbicacionesViewModel>(context, listen: false);

    final origen =
        vm.getUbicacion(_origenArea!, _origenEspacio!, _origenNivel!);
    final destino =
        vm.getUbicacion(_destinoArea!, _destinoEspacio!, _destinoNivel!);

    final numeroSerie = origen?.numberSerie;
    if (numeroSerie == null || numeroSerie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('❌ El número de serie del contenedor origen es inválido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (origen == null || destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al encontrar ubicaciones.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final exito = await vm.registrarReacomodo(
      contenedorActualId: origen.id.toString(),
      contenedorNuevoId: destino.id.toString(),
      numberSerie: numeroSerie,
      siteId: _currentSiteId,
    );

    if (exito) {
      // Volver a cargar ubicaciones desde la API
      await vm.cargarUbicacionesDesdeApi(); // 👈 Recarga desde el servidor

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reacomodo registrado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpiar selección
      setState(() {
        _origenArea = null;
        _origenEspacio = null;
        _origenNivel = null;
        _destinoArea = null;
        _destinoEspacio = null;
        _destinoNivel = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo registrar el reacomodo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPisoCamionMap() {
    return Consumer<UbicacionesViewModel>(
      builder: (context, vm, _) {
        final String? areaSeleccionada = widget.initialArea;
        final String? espacioSeleccionado = widget.initialEspacio;
        final String? nivelSeleccionado = widget.initialNivel;

        if (areaSeleccionada == null ||
            espacioSeleccionado == null ||
            nivelSeleccionado == null) {
          return const Center(child: Text('Ubicación inicial incompleta.'));
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Área: $areaSeleccionada | Espacio: $espacioSeleccionado | Nivel: $nivelSeleccionado',
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 24),

                  /// Grid flexible
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
                            _mostrarModalEspaciosPisoCamion(context, vm, area);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Cargando espacios, por favor espera..."),
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

  // Widget buildCamionPisoMap() {
  //   return Consumer<UbicacionesViewModel>(
  //     builder: (context, vm, _) {
  //       final String? areaInicial = widget.initialArea;
  //       final String? espacioInicial = widget.initialEspacio;
  //       final String? nivelInicial = widget.initialNivel;

  //       final areas = vm.getAreas();

  //       return SingleChildScrollView(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Selecciona un área para colocar el contenedor:',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             // Text(
  //             //   'Área: ${areaInicial ?? " "} | Espacio: ${espacioInicial ?? " "} | Nivel: ${nivelInicial ?? " "}',
  //             //   style: const TextStyle(fontSize: 15),
  //             // ),
  //             const SizedBox(height: 20),

  //             /// Áreas en cuadrícula adaptativa
  //             GridView.builder(
  //               shrinkWrap: true,
  //               physics: const NeverScrollableScrollPhysics(),
  //               itemCount: areas.length,
  //               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
  //                 maxCrossAxisExtent: 250,
  //                 mainAxisSpacing: 20,
  //                 crossAxisSpacing: 20,
  //                 childAspectRatio: 1.1,
  //               ),
  //               itemBuilder: (context, index) {
  //                 final area = areas[index];
  //                 final bool esAreaSeleccionada = area == areaInicial;

  //                 return GestureDetector(
  //                   onTap: () {
  //                     // ✅ No mostramos la modal hasta que haya datos
  //                     if (vm.getEspaciosPorArea(area).isNotEmpty) {
  //                       _mostrarModalEspacios(context, vm, area);
  //                     } else {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(
  //                           content:
  //                               Text("Cargando espacios, por favor espera..."),
  //                         ),
  //                       );
  //                     }
  //                   },
  //                   child: AnimatedContainer(
  //                     duration: const Duration(milliseconds: 200),
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: esAreaSeleccionada
  //                           ? Colors.green.shade200
  //                           : Colors.white,
  //                       borderRadius: BorderRadius.circular(16),
  //                       border: Border.all(
  //                         color: esAreaSeleccionada
  //                             ? Colors.green
  //                             : Colors.green.shade300,
  //                         width: esAreaSeleccionada ? 3 : 1,
  //                       ),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.grey.withOpacity(0.1),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 4),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         'Área $area',
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: esAreaSeleccionada
  //                               ? FontWeight.bold
  //                               : FontWeight.w500,
  //                           color: esAreaSeleccionada
  //                               ? Colors.green.shade900
  //                               : Colors.blueGrey.shade800,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

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

  // void _mostrarModalEspacios(
  //     BuildContext context, UbicacionesViewModel vm, String area) {
  //   final espacios = vm.getEspaciosPorArea(area);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Container(
  //           padding: const EdgeInsets.all(20),
  //           height: 500,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Área: $area',
  //                 style: const TextStyle(
  //                     fontWeight: FontWeight.bold, fontSize: 18),
  //               ),
  //               const SizedBox(height: 10),
  //               const Text('Selecciona un espacio:'),
  //               const SizedBox(height: 16),
  //               Expanded(
  //                 child: GridView.extent(
  //                   maxCrossAxisExtent: 140,
  //                   crossAxisSpacing: 12,
  //                   mainAxisSpacing: 12,
  //                   children: espacios.map((espacio) {
  //                     return GestureDetector(
  //                       onTap: () {
  //                         _mostrarModalNiveles(context, vm, area, espacio);
  //                       },
  //                       child: AnimatedContainer(
  //                         duration: const Duration(milliseconds: 200),
  //                         padding: const EdgeInsets.all(12),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(12),
  //                           border: Border.all(
  //                             color: Colors.green.shade300,
  //                             width: 1,
  //                           ),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.grey.withOpacity(0.1),
  //                               blurRadius: 6,
  //                               offset: const Offset(0, 3),
  //                             ),
  //                           ],
  //                         ),
  //                         alignment: Alignment.center,
  //                         child: Text(
  //                           'Espacio $espacio',
  //                           textAlign: TextAlign.center,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w500,
  //                             color: Colors.blueGrey.shade800,
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 350,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveles de espacio:  $espacio',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    //itemCount: niveles.length,
                    itemCount: nivelesOrdenados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ubicacion = niveles[index];
                      final ocupado = vm.nivelEstaOcupado(
                        ubicacion.area,
                        ubicacion.espacio,
                        ubicacion.nivel,
                      );

                      final bool esNivelSeleccionado =
                          ubicacion.nivel == nivelSeleccionado &&
                              ubicacion.area == areaSeleccionada &&
                              ubicacion.espacio == espacioSeleccionado;

                      final bool estatusEsUsed = ubicacion.estado == 'Used';

                      Color tileColor;
                      if (esNivelSeleccionado) {
                        tileColor = Colors.orange.shade200; // Seleccionado
                      } else if (ubicacion.estado == 'Used') {
                        tileColor = Colors.red.shade200; // Ocupado
                      } else {
                        tileColor = Colors.green.shade200; // Libre
                      }

                      return InkWell(
                        onTap: ubicacion.estado == 'Free'
                            ? () {
                                _mostrarConfirmacionSeleccion(
                                  context,
                                  ubicacion.area,
                                  ubicacion.espacio,
                                  ubicacion.nivel,
                                  ocupado,
                                  ubicacion.id,
                                  _currentSiteId!,
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: esNivelSeleccionado
                                  ? Colors.green.shade400
                                  : Colors.transparent,
                              width: esNivelSeleccionado ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nivel ${ubicacion.nivel}',
                                    style: TextStyle(
                                      fontWeight: esNivelSeleccionado
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: estatusEsUsed
                                          ? Colors.black
                                          : Colors.black,
                                    ),
                                  ),
                                  if (esNivelSeleccionado)
                                    Text(
                                      'Contenedor: ${widget.containerNumber}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                ],
                              ),
                              if (ocupado)
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20)
                              else if (esNivelSeleccionado)
                                const Icon(Icons.check_circle,
                                    color: Colors.deepOrange, size: 20),
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

  // void _mostrarModalNiveles(BuildContext context, UbicacionesViewModel vm,
  //     String area, String espacio) {
  //   final niveles = vm.getNivelesPorEspacioCamionPiso(area, espacio);
  //   niveles.sort((a, b) => b.compareTo(a));
  //   final ubicaciones = vm.getUbicacionesPorAreaEspacioYNivel(area, espacio);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         child: Container(
  //           padding: const EdgeInsets.all(20),
  //           constraints: const BoxConstraints(maxHeight: 450, maxWidth: 360),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Niveles disponibles para: $espacio',
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Expanded(
  //                 child: niveles.isEmpty
  //                     ? const Center(
  //                         child: Text(
  //                           'No hay niveles disponibles.',
  //                           style: TextStyle(color: Colors.grey),
  //                         ),
  //                       )
  //                     : ListView.separated(
  //                         itemCount: niveles.length,
  //                         separatorBuilder: (_, __) =>
  //                             const SizedBox(height: 10),
  //                         itemBuilder: (context, index) {
  //                           final nivel = niveles[index];
  //                           final ocupado = vm.nivelEstaOcupadoCamionPiso(
  //                               area, espacio, nivel);
  //                           Ubicacion? ubicacion;
  //                           try {
  //                             ubicacion = ubicaciones
  //                                 .firstWhere((u) => u.nivel == nivel);
  //                           } catch (_) {
  //                             ubicacion = null;
  //                           }

  //                           Color bgColor = ocupado
  //                               ? Colors.red.shade100
  //                               : Colors.green.shade100;
  //                           Color textColor = ocupado
  //                               ? Colors.red.shade900
  //                               : Colors.green.shade800;

  //                           return GestureDetector(
  //                             onTap: ocupado
  //                                 ? null
  //                                 : () {
  //                                     _destinoArea = area;
  //                                     _destinoEspacio = espacio;
  //                                     _destinoNivel = nivel;

  //                                     final _id = ubicacion?.id;
  //                                     _showConfirmationTruckFloor(
  //                                         context,
  //                                         area,
  //                                         espacio,
  //                                         nivel,
  //                                         ocupado,
  //                                         _id!,
  //                                         _currentSiteId!);

  //                                     ScaffoldMessenger.of(context)
  //                                         .showSnackBar(
  //                                       SnackBar(
  //                                         content: Text(
  //                                           'Seleccionado: $area - $espacio - $nivel',
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                             child: AnimatedContainer(
  //                               duration: const Duration(milliseconds: 200),
  //                               padding: const EdgeInsets.symmetric(
  //                                   horizontal: 16, vertical: 14),
  //                               decoration: BoxDecoration(
  //                                 color: bgColor,
  //                                 borderRadius: BorderRadius.circular(12),
  //                                 border: Border.all(
  //                                   color: ocupado
  //                                       ? Colors.red.shade300
  //                                       : Colors.green.shade400,
  //                                   width: 1.5,
  //                                 ),
  //                               ),
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Text(
  //                                     'Nivel $nivel',
  //                                     style: TextStyle(
  //                                       fontWeight: FontWeight.w600,
  //                                       color: textColor,
  //                                     ),
  //                                   ),
  //                                   Icon(
  //                                     ocupado
  //                                         ? Icons.lock
  //                                         : Icons.check_circle_outline,
  //                                     color: ocupado
  //                                         ? Colors.red.shade400
  //                                         : Colors.green.shade600,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

// Simulador de estado ocupado (debes ajustar a tu lógica real)
  bool nivelEstaOcupado(String area, String espacio, String nivel) {
    return int.tryParse(nivel) != null && int.parse(nivel) % 2 == 0;
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

                _destinoArea = area;

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
            '¿Confirmas la ubicación?\n\nÁrea: $area\nEspacio: $espacio\nNivel: $nivel  ID: $id\Movimiento id: ${widget.movementId.toString()}\nNumero de serie: ${widget.containerNumber}\n Sitio id:${currentSiteId}'
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
                _destinoArea = area;
                _destinoEspacio = espacio;
                _destinoNivel = nivel;

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

  // Widget _buildTextField({
  //   required String label,
  //   required TextEditingController controller,
  //   void Function(String)? onChanged,
  //   TextInputType? inputType,
  //   int? minLines,
  //   int? maxLines,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     onChanged: onChanged,
  //     keyboardType: inputType,
  //     minLines: minLines,
  //     maxLines: maxLines,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //     ),
  //   );
  // }
}

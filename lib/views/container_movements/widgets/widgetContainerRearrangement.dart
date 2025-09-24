import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class ContainerRearrangementScreen extends StatefulWidget {
  const ContainerRearrangementScreen({Key? key}) : super(key: key);

  @override
  State<ContainerRearrangementScreen> createState() =>
      _ContainerRearrangementScreenState();
}

class _ContainerRearrangementScreenState
    extends State<ContainerRearrangementScreen> {
  late UbicacionesViewModel vm;
  String? error;
  bool isLoading = true;
  String? currentSiteId;

  String? _origenArea;
  String? _origenEspacio;
  String? _origenNivel;
  String? _numeroSerieOrigen;

  String? _destinoArea;
  String? _destinoEspacio;
  String? _destinoNivel;

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

    // Inicializar ViewModel desde Provider
    vm = Provider.of<UbicacionesViewModel>(context, listen: false);

    // Si necesitas cargar ubicaciones o datos al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = UserSession();
      await session.loadFromPrefs();

      setState(() {
        currentSiteId = session.siteId;
      });

      // ✅ Ahora sí cargamos ubicaciones
      await _loadUbicaciones(); // Solo si necesitas precargar datos
    });
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<UbicacionesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reacomodo de contenedores',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione ubicación de origen:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(child: buildAreaMapReacomodo(vm, isOrigen: true)),
            const Divider(height: 32),
            const Text(
              'Seleccione ubicación de destino:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(child: buildAreaMapReacomodo(vm, isOrigen: false)),
          ],
        ),
      ),
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
      siteId: currentSiteId,
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
}

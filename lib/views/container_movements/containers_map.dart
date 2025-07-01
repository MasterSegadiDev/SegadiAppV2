import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

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
  });

  @override
  State<ContainersMapScreen> createState() => _ContainersMapScreenState();
}

class _ContainersMapScreenState extends State<ContainersMapScreen> {
  bool _isLoading = true;
  String? _error;

  String? _origenArea;
  String? _origenEspacio;
  String? _origenNivel;

// Para guardar la selección de destino
  String? _destinoArea;
  String? _destinoEspacio;
  String? _destinoNivel;

  final _numeroSerieController = TextEditingController();
  final TextEditingController _pesoBrutoController = TextEditingController();
  final _nombreImagenPesoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
  }

  Future<void> _loadUbicaciones() async {
    try {
      final vm = Provider.of<UbicacionesViewModel>(context, listen: false);
      await vm.cargarUbicacionesDesdeApi();
    } catch (e) {
      _error = 'Error al cargar ubicaciones';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario(UbicacionesViewModel vm) {
    _pesoBrutoController.clear();
    _numeroSerieController.clear();
    _nombreImagenPesoController.clear();
    vm.clearSelectedImage();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UbicacionesViewModel>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (widget.movementType == 'Piso-Camion') {
      return Scaffold(
        appBar: AppBar(title: const Text('Movimiento Piso - Camión')),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seleccione ubicación de destino:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                  child: _buildPisoCamionMap(
                vm,
              )),
            ],
          ),
        ),
      );
    }

    if (widget.movementType == 'Camion-Piso') {
      return Scaffold(
        appBar: AppBar(title: const Text('Movimiento Camion Piso')),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seleccione ubicación de destino:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(child: _buildCamionPisoMap(vm)),
            ],
          ),
        ),
      );
    }

    if (widget.movementType == 'Reacomodo') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reacomodo de contenedores',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Color.fromARGB(255, 33, 150, 91),
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
              Expanded(child: _buildAreaMap(vm, isOrigen: true)),
              const Divider(height: 32),
              const Text('Seleccione ubicación de destino:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(child: _buildAreaMap(vm, isOrigen: false)),
            ],
          ),
        ),
      );
    }
    if (widget.movementType == 'Pesaje') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pesaje de contenedor',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Color.fromARGB(255, 33, 150, 91),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Formulario de Pesaje',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),

                        // Número de Serie
                        TextField(
                          controller: _numeroSerieController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Serie',
                            prefixIcon: Icon(Icons.confirmation_number),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Peso Bruto
                        _buildTextField(
                          label: 'Peso en (Tonelada)',
                          controller: _pesoBrutoController,
                          inputType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                        const SizedBox(height: 16),

                        // Nombre de imagen
                        TextField(
                          controller: _nombreImagenPesoController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la evidencia (Imagen)',
                            prefixIcon: Icon(Icons.image),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón capturar imagen
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: vm.pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Capturar Imagen'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mostrar imagen si existe
                        if (vm.selectedImage != null)
                          Column(
                            children: [
                              const Text(
                                'Imagen capturada:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  vm.selectedImage!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: vm.clearSelectedImage,
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Eliminar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: vm.pickImageFromCamera,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Cambiar'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // Botones de acción
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final peso = _pesoBrutoController.text.trim();
                                  final serie =
                                      _numeroSerieController.text.trim();
                                  final name =
                                      _nombreImagenPesoController.text.trim();
                                  final imagen = vm.selectedImage;

                                  if (peso.isEmpty ||
                                      serie.isEmpty ||
                                      name.isEmpty ||
                                      imagen == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Por favor completa todos los campos y captura una imagen.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  vm.registrarPesaje(
                                    serie: serie,
                                    peso: peso,
                                    nameImage: name,
                                    image: imagen,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pesaje registrado'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save),
                                label: const Text('Guardar Pesaje'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                _limpiarFormulario(vm);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Movimiento de Contenedores')),
      body: Center(
        child: Text('Vista no implementada para: ${widget.movementType}'),
      ),
    );
  }

  Widget _buildAreaMap(UbicacionesViewModel vm, {required bool isOrigen}) {
    final areas = vm.getAreas();

    return ListView.builder(
      itemCount: areas.length,
      itemBuilder: (context, areaIndex) {
        final area = areas[areaIndex];
        final espacios = vm.getEspaciosPorArea(area);

        return ExpansionTile(
          title: Text('Área $area'),
          children: espacios.map((espacio) {
            final niveles = vm.getNivelesPorEspacio(area, espacio);

            final ocupadas = vm
                .getUbicacionesPorAreaEspacioYNivel(area, espacio, null)
                .where((u) => u.estado != 'Free')
                .map((u) => u.nivel)
                .toSet();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Espacio $espacio',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: niveles.map((nivel) {
                      final ocupado = ocupadas.contains(nivel);
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ocupado ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _onNivelSeleccionado(
                          area: area,
                          espacio: espacio,
                          nivel: nivel as String,
                          isOrigen: isOrigen,
                        ),
                        child: Text(nivel as String),
                      );
                    }).toList(),
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _onNivelSeleccionado({
    required String area,
    required String espacio,
    required String nivel,
    required bool isOrigen,
  }) {
    setState(() {
      if (isOrigen) {
        _origenArea = area;
        _origenEspacio = espacio;
        _origenNivel = nivel;
      } else {
        _destinoArea = area;
        _destinoEspacio = espacio;
        _destinoNivel = nivel;
      }
    });

    final tipo = isOrigen ? 'Origen' : 'Destino';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$tipo seleccionado: $area - $espacio - $nivel')),
    );

    // Si ambos están seleccionados, pedir confirmación
    if (_origenArea != null &&
        _origenEspacio != null &&
        _origenNivel != null &&
        _destinoArea != null &&
        _destinoEspacio != null &&
        _destinoNivel != null) {
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

    if (origen == null || destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al encontrar ubicaciones.')),
      );
      return;
    }

    await vm.registrarReacomodo(
      contenedorActualId: origen.id.toString(),
      contenedorNuevoId: destino.id.toString(),
      numberSerie: origen.numberSerie,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reacomodo registrado exitosamente')),
    );

    setState(() {
      _origenArea = null;
      _origenEspacio = null;
      _origenNivel = null;
      _destinoArea = null;
      _destinoEspacio = null;
      _destinoNivel = null;
    });
  }

  Widget _buildPisoCamionMap(UbicacionesViewModel vm) {
    final String? areaSeleccionada = widget.initialArea;
    final String? espacioSeleccionado = widget.initialEspacio;
    final String? nivelSeleccionado = widget.initialNivel;

    if (areaSeleccionada == null ||
        espacioSeleccionado == null ||
        nivelSeleccionado == null) {
      return const Center(child: Text('Ubicación inicial incompleta.'));
    }

    final areas = vm.getAreas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación actual seleccionada:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Area: $areaSeleccionada | Espacio: $espacioSeleccionado | Nivel: $nivelSeleccionado',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          /// Áreas en cuadrícula
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: areas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final area = areas[index];
              final bool esAreaSeleccionada = area == areaSeleccionada;

              return GestureDetector(
                onTap: () => _mostrarModalEspaciosPisoCamion(context, vm, area),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: esAreaSeleccionada
                        ? Colors.orange.shade300
                        : Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: esAreaSeleccionada
                          ? Colors.deepOrange
                          : Colors.blueGrey,
                      width: esAreaSeleccionada ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Area $area',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCamionPisoMap(UbicacionesViewModel vm) {
    final String? areaInicial = widget.initialArea;
    final String? espacioInicial = widget.initialEspacio;
    final String? nivelInicial = widget.initialNivel;

    final areas = vm.getAreas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación actual seleccionada:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Area: ${areaInicial ?? "-"} | Espacio: ${espacioInicial ?? "-"} | Nivel: ${nivelInicial ?? "-"}',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          /// Áreas en cuadrícula
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: areas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final area = areas[index];
              return GestureDetector(
                onTap: () => _mostrarModalEspacios(context, vm, area),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Center(
                    child: Text(
                      'Área $area',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _mostrarModalEspaciosPisoCamion(
      BuildContext context, UbicacionesViewModel vm, String area) {
    final espacios = vm.getEspaciosPorArea(area);
    final String? espacioSeleccionado = widget.initialEspacio;
    final String? areaSeleccionada = widget.initialArea;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Área: $area',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                const Text('Selecciona un espacio:'),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: espacios.map((espacio) {
                      final bool esEspacioSeleccionado =
                          espacio == espacioSeleccionado &&
                              area == areaSeleccionada;

                      return GestureDetector(
                        onTap: () {
                          _mostrarModalNivelesPisoCamion(
                              context, vm, area, espacio);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: esEspacioSeleccionado
                                ? Colors.orange.shade300
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: esEspacioSeleccionado
                                  ? Colors.deepOrange
                                  : Colors.transparent,
                              width: esEspacioSeleccionado ? 3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Espacio $espacio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: esEspacioSeleccionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

  void _mostrarModalEspacios(
      BuildContext context, UbicacionesViewModel vm, String area) {
    final espacios = vm.getEspaciosPorArea(area);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Área: $area',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                const Text('Selecciona un espacio:'),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: espacios.map((espacio) {
                      return GestureDetector(
                        onTap: () {
                          _mostrarModalNiveles(context, vm, area, espacio);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text('Espacio $espacio',
                              textAlign: TextAlign.center),
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
            height: 400,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Niveles de $espacio',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: niveles.length,
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

                      return ListTile(
                        tileColor: esNivelSeleccionado
                            ? Colors.orange.shade300
                            : ocupado
                                ? Colors.red.shade100
                                : Colors.green[100],
                        title: Text(
                          'Nivel ${ubicacion.nivel} ${ocupado ? "(Ocupado)" : ""}',
                          style: TextStyle(
                            fontWeight: esNivelSeleccionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: estatusEsUsed ? Colors.black : Colors.grey,
                          ),
                        ),
                        enabled: estatusEsUsed,
                        onTap: estatusEsUsed
                            ? () {
                                Navigator.pop(context);
                                _mostrarConfirmacionSeleccion(
                                  context,
                                  ubicacion.area,
                                  ubicacion.espacio,
                                  ubicacion.nivel,
                                  ocupado,
                                  ubicacion.id,
                                );
                              }
                            : null,
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

  void _mostrarModalNiveles(BuildContext context, UbicacionesViewModel vm,
      String area, String espacio) {
    final niveles = vm.getNivelesPorEspacioCamionPiso(area, espacio);
    print('NIVELES CAMION PISO ${niveles}');
    final ubicaciones = vm.getUbicacionesPorAreaEspacioYNivel(
        area, espacio); // [{id, nivel, estatus}, ...]
    print('UBICACIONES DE LOS NIVELES: ${ubicaciones}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 400,
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Niveles de $espacio',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: niveles.length,
                    itemBuilder: (context, index) {
                      final nivel = niveles[index];

                      final ocupado =
                          vm.nivelEstaOcupadoCamionPiso(area, espacio, nivel);

                      Ubicacion? ubicacion;
                      try {
                        ubicacion =
                            ubicaciones.firstWhere((u) => u.nivel == nivel);
                      } catch (_) {
                        ubicacion = null;
                      }

                      return ListTile(
                        tileColor:
                            ocupado ? Colors.grey[300] : Colors.green[100],
                        title: Text('Nivel $nivel'),
                        onTap: ocupado
                            ? null
                            : () {
                                _destinoArea = area;
                                _destinoEspacio = espacio;
                                _destinoNivel = nivel;
                                final _id = ubicacion?.id;
                                // Navigator.pop(context); // cerrar niveles
                                // Navigator.pop(context); // cerrar espacios

                                _showConfirmationTruckFloor(context, area,
                                    espacio, nivel, ocupado, _id!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Seleccionado: $area - $espacio - $nivel'),
                                  ),
                                );
                                // _confirmarPisoCamion();
                              },
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

// Simulador de estado ocupado (debes ajustar a tu lógica real)
  bool nivelEstaOcupado(String area, String espacio, String nivel) {
    return int.tryParse(nivel) != null && int.parse(nivel) % 2 == 0;
  }

  void _mostrarConfirmacionSeleccion(BuildContext context, String area,
      String espacio, String nivel, bool ocupado, String id) {
    final rootContext = context; // <-- guardar el contexto válido

    showDialog(
      context: rootContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar selección'),
          content: Text(
            '¿Confirmas la ubicación?\n\nÁrea: $area\nEspacio: $espacio\nNivel: $nivel'
            '${ocupado ? "\n\n⚠️ Este nivel está ocupado." : ""}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // cerrar el diálogo primero

                final vm = Provider.of<UbicacionesViewModel>(
                  rootContext, // usamos el context externo
                  listen: false,
                );

                // Guardamos datos
                _destinoArea = area;
                _destinoEspacio = espacio;
                _destinoNivel = nivel;

                await vm.registrarMovimientoPisoCamion(
                  destinoId: id,
                  movementId: widget.movementId.toString(),
                  numberSerie: widget.containerNumber!,
                );

                // Mostrar confirmación
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content:
                        Text('Ubicación confirmada: $area - $espacio - $nivel'),
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationTruckFloor(BuildContext context, String area,
      String espacio, String nivel, bool ocupado, String id) {
    final rootContext = context; // <-- guardar el contexto válido

    showDialog(
      context: rootContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar selección'),
          content: Text(
            '¿Confirmas la ubicación?\n\nÁrea: $area\nEspacio: $espacio\nNivel: $nivel'
            '${ocupado ? "\n\n⚠️ Este nivel está ocupado." : ""}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // cerrar el diálogo primero

                final vm = Provider.of<UbicacionesViewModel>(
                  rootContext, // usamos el context externo
                  listen: false,
                );

                // Guardamos datos
                _destinoArea = area;
                _destinoEspacio = espacio;
                _destinoNivel = nivel;

                await vm.registrarMovimientoCamionPiso(
                  destinoId: id,
                  movementId: widget.movementId.toString(),
                  numberSerie: widget.containerNumber!,
                );

                // Mostrar confirmación
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content:
                        Text('Ubicación confirmada: $area - $espacio - $nivel'),
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    void Function(String)? onChanged,
    TextInputType? inputType,
    int? minLines,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: inputType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

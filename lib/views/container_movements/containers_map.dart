import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/upperCaseTextFormatter.dart';

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

  var _numeroSerieController = TextEditingController();
  final TextEditingController _pesoBrutoController = TextEditingController();
  final _nombreImagenPesoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
    _numeroSerieController = TextEditingController(
      text: widget.containerNumber ?? '', // si viene null, queda vacío
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

  void _limpiarFormulario(UbicacionesViewModel vm) {
    _pesoBrutoController.clear();
    _numeroSerieController.clear();
    _nombreImagenPesoController.clear();
    vm.clearSelectedImage();
  }

  @override
  Widget build(BuildContext context) {
    print('TIPO DE MOVIMIENTO : ${widget.movementType} '
        ' NUMERO DE SERIE: ${widget.containerNumber}');
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
        appBar: AppBar(
          title: Text('Movimiento Piso - Camión',
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        appBar: AppBar(
          title: Text('Movimiento Camión - Piso',
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          title: Text('Recomodo de contenedores',
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A),
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
          title: Text('Pesaje de contenedores',
              style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF2C522A),
        ),
        body: vm.isSaving
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Registrando pesaje...'),
                  ],
                ),
              )
            : SafeArea(
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
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
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(11),
                                  UpperCaseTextFormatter(), // solo letras y números en mayúscula
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Peso Bruto
                              // _buildTextField(
                              //   label: 'Peso en (Tonelada)',
                              //   controller: _pesoBrutoController,
                              // ),

                              TextField(
                                controller: _pesoBrutoController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Peso Bruto (Toneladas)',
                                  prefixIcon: Icon(Icons.monitor_weight),
                                  border: OutlineInputBorder(),
                                ),
                                inputFormatters: [
                                  DecimalTextInputFormatter(
                                      decimalRange:
                                          2), // permite 0.00 hasta 99999.99
                                ],
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
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                  UpperCaseTextFormatter(), // solo letras y números en mayúscula
                                ],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      onPressed: () async {
                                        final peso =
                                            _pesoBrutoController.text.trim();
                                        final serie =
                                            _numeroSerieController.text.trim();
                                        final name = _nombreImagenPesoController
                                            .text
                                            .trim();
                                        final imagen = vm.selectedImage;

                                        if (peso.isEmpty ||
                                            serie.isEmpty ||
                                            name.isEmpty ||
                                            imagen == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Por favor completa todos los campos y captura una imagen.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        await vm.registrarPesaje(
                                          serie: serie,
                                          peso: peso,
                                          nameImage: name,
                                          image: imagen,
                                        );

                                        if (vm.registroMensaje != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text(vm.registroMensaje!),
                                              backgroundColor: vm
                                                      .registroMensaje!
                                                      .contains('✅')
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          );
                                        }

                                        if (vm.registroMensaje!.contains('✅')) {
                                          _limpiarFormulario(vm);
                                        }
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                final niveles = vm.getNivelesPorEspacio(area, espacio);

                final ubicaciones =
                    vm.getUbicacionesPorAreaEspacioYNivel(area, espacio, null);
                final ubicacionesMap = {
                  for (var u in ubicaciones) u.nivel: u,
                };

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        children: niveles.map((nivel) {
                          final ubicacion = ubicacionesMap[nivel];
                          final ocupado =
                              ubicacion != null && ubicacion.estado != 'Free';
                          final numeroSerie =
                              ocupado ? (ubicacion.numberSerie ?? 'N/A') : null;

                          return SizedBox(
                            width: 160,
                            height: 80,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ocupado
                                    ? Colors.red.shade300
                                    : Colors.green.shade400,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(8),
                              ),
                              onPressed: () => _onNivelSeleccionado(
                                area: area,
                                espacio: espacio,
                                nivel: nivel,
                                isOrigen: isOrigen,
                              ),
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
                                  if (ocupado) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      numeroSerie!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
      numberSerie: origen.numberSerie,
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
                'Area: $areaSeleccionada | Espacio: $espacioSeleccionado | Nivel: $nivelSeleccionado',
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 24),

              /// Grid flexible
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

          /// Áreas en cuadrícula adaptativa
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: areas.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.1, // Proporción igual a _buildPisoCamionMap
            ),
            itemBuilder: (context, index) {
              final area = areas[index];
              final bool esAreaSeleccionada = area == areaInicial;

              return GestureDetector(
                onTap: () => _mostrarModalEspacios(context, vm, area),
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
  }

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
                        tileColor = Colors.orange.shade200;
                      } else if (ocupado) {
                        tileColor = Colors.red.shade100;
                      } else {
                        tileColor = Colors.green.shade100;
                      }

                      return InkWell(
                        onTap: estatusEsUsed
                            ? () {
                                //Navigator.pop(context);
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: esNivelSeleccionado
                                  ? Colors.green
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
                                          : Colors.grey.shade600,
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
                                      _destinoArea = area;
                                      _destinoEspacio = espacio;
                                      _destinoNivel = nivel;

                                      final _id = ubicacion?.id;
                                      _showConfirmationTruckFloor(context, area,
                                          espacio, nivel, ocupado, _id!);

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
                _destinoArea = area;
                _destinoEspacio = espacio;
                _destinoNivel = nivel;

                bool exito = false;

                try {
                  await vm.registrarMovimientoCamionPiso(
                    destinoId: id,
                    movementId: widget.movementId.toString(),
                    numberSerie: widget.containerNumber!,
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

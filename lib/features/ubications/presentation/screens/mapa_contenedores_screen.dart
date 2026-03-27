import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';
import 'package:segadi/features/ubications/widgets/mapa_espacio_item.dart';
import 'package:segadi/features/ubications/widgets/selector_ingreso_modal.dart';
import 'package:segadi/features/ubications/widgets/selector_niveles_modal.dart';

class GestionInventarioPage extends StatefulWidget {
  const GestionInventarioPage({super.key});

  @override
  State<GestionInventarioPage> createState() => _GestionInventarioPageState();
}

class _GestionInventarioPageState extends State<GestionInventarioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ESTO ES VITAL: Limpia cualquier residuo de navegación previa
      context.read<UbicacionesMapaViewModel>().limpiarEstado();
      context.read<UbicacionesMapaViewModel>().cancelarReacomodo();
      context.read<UbicacionesMapaViewModel>().cargarMapa();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UbicacionesMapaViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mapa de Ubicaciones',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.cargarMapa(),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2C522A),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.ubicacionesMapEntity == null
              ? const Center(child: Text("Error al cargar el mapa"))
              : _MapaHorizontalView(vm: vm),
    );
  }
}

class _MapaHorizontalView extends StatelessWidget {
  final UbicacionesMapaViewModel vm;
  const _MapaHorizontalView({required this.vm});

  @override
  Widget build(BuildContext context) {
    final data = vm.ubicacionesMapEntity!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leyenda superior
        if (vm.enModoReacomodo) _buildBarraReacomodo(context),

        // Leyenda superior
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _statusLabel(Colors.green, "Libre"),
              const SizedBox(width: 10),
              _statusLabel(Colors.red, "Lleno"),
            ],
          ),
        ),

        // El scroll de áreas sigue siendo HORIZONTAL
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: data.areas.length,
            itemBuilder: (context, index) {
              final area = data.areas[index];
              return _buildAreaColumn(context, area, data);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarraReacomodo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      color: Colors.orange[900],
      child: Row(
        children: [
          const Icon(Icons.sync_alt, color: Colors.white, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MODO REACOMODO",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  "Moviendo: ${vm.serieEnGancho}. Toque el espacio de destino en el mapa.",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              vm.cancelarReacomodo();
            },
            child: const Text("CANCELAR"),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaColumn(
      BuildContext context, AreaEntity area, UbicacionesMapEntity data) {
    final espaciosNumeros = vm.getEspaciosNumericos(area.nombre);
    if (espaciosNumeros.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[350]!),
      ),
      child: Column(
        children: [
          // Título del Bloque/Área
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Text(
              "ÁREA ${area.nombre}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          // Cuadrícula de 3 columnas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: espaciosNumeros.length,
              itemBuilder: (context, idx) {
                final numEspacio = espaciosNumeros[idx];
                final niveles =
                    vm.getNivelesDelEspacio(area.nombre, numEspacio);

                // AQUÍ MANDAS LLAMAR TU WIDGET SEPARADO
                return MapaEspacioItem(
                  area: area.nombre,
                  espacio: numEspacio,
                  niveles: niveles,
                  // AQUÍ ES DONDE CONECTAS EL CLICK CON LA FUNCIÓN "CEREBRO"
                  onTap: () => _gestionarClicEspacio(
                      context, area.nombre, numEspacio, niveles, vm),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ESTA FUNCION VALIDA EL TIPO DE MOVIMIENTO, DE ACUERDO AL TIPO DE MOVIMIENTO ES COMO MOSTRARA LA MODAL.
  void _gestionarClicEspacio(
      BuildContext context,
      String areaNom,
      String espNom,
      List<UbicacionEntity> niveles,
      UbicacionesMapaViewModel vm) {
    print(
        'DEBUG: Clic en $areaNom-$espNom | Mov: ${vm.movimientoActual} | Fase: ${vm.faseReacomodo}');

    // 1. PRIORIDAD MÁXIMA: ATERRIZAJE (Soltar el contenedor)
    // Se activa si ya tenemos algo en el "gancho" (Reacomodo en curso)
    if (vm.faseReacomodo == FaseReacomodo.destino) {
      final bool tieneEspacioLibre =
          niveles.any((n) => n.estatus.toLowerCase() == 'free');

      if (tieneEspacioLibre) {
        _confirmarAterrizajeReacomodo(context, areaNom, espNom, niveles);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Espacio sin niveles libres para aterrizar")),
        );
      }
      return;
    }

    // 2. FLUJOS DE ORIGEN (Cuando NO estamos aterrizando)
    final tipo = vm.movimientoActual;

    // --- CASO A: REACOMODO MANUAL (Botón Naranja del listado o del mapa) ---
    if (tipo == TipoMovimiento.reacomodo) {
      final bool tieneContenedores =
          niveles.any((n) => n.estatus.toLowerCase() == 'used');

      if (tieneContenedores) {
        _abrirSelectorNiveles(context, areaNom, espNom, niveles, vm);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Este espacio está vacío, selecciona un contenedor para mover.")),
        );
      }
      return;
    }

    // --- CASO B: DESPACHO (PISO A CAMIÓN) ---
    if (tipo == TipoMovimiento.pisoCamion) {
      _abrirSelectorNiveles(context, areaNom, espNom, niveles, vm);
      return;
    }

    // --- CASO C: INGRESO (CAMIÓN A PISO) ---
    if (tipo == TipoMovimiento.camionPiso) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => SelectorIngresoModal(
          area: areaNom,
          espacio: espNom,
          niveles: niveles,
          vm: vm,
        ),
      );
      return;
    }
  }

// Función auxiliar para no repetir código del BottomSheet
  void _abrirSelectorNiveles(BuildContext context, String area, String espacio,
      List<UbicacionEntity> niveles, UbicacionesMapaViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SelectorNivelesModal(
        area: area,
        espacio: espacio,
        niveles: niveles,
        vm: vm,
      ),
    );
  }
  // funcion para mostrar la modal de seleccion camion - piso

  Widget _statusLabel(Color color, String text) {
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Importante para que el Wrap sepa cuánto mide
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmarAterrizajeReacomodo(BuildContext context, String area,
      String numEspacio, List<UbicacionEntity> niveles) {
    // Buscamos el primer nivel disponible (Sustento)
    // Filtramos los que están 'free' y agarramos el menor (ej. Nivel 1 antes que el 2)
    final nivelesLibres =
        niveles.where((n) => n.estatus.toLowerCase() == 'free').toList();
    nivelesLibres.sort((a, b) => a.nivel.compareTo(b.nivel));

    if (nivelesLibres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay niveles libres en este espacio")),
      );
      return;
    }

    final destino = nivelesLibres.first; // El nivel más bajo disponible

    showDialog(
      context: context,
      barrierDismissible: false, // Obligamos a que confirme o cancele
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.move_to_inbox, color: Colors.orange),
            SizedBox(width: 10),
            Text("Confirmar Movimiento"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Se realizará el siguiente reacomodo:"),
            const SizedBox(height: 15),
            _datoConfirmacion("Contenedor:", vm.serieEnGancho),
            _datoConfirmacion("Destino:", "Área $area - Espacio $numEspacio"),
            _datoConfirmacion("Nivel:", "Nivel ${destino.nivel}"),
            const SizedBox(height: 15),
            const Text(
              "¿Confirmar posición final?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.limpiarEstado();
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Ejecutamos la lógica en el ViewModel
              vm.finalizarReacomodo(destino);

              print('confirmando y ubicando ${destino}');
            },
            child: const Text("Confirmar y Ubicar"),
          ),
        ],
      ),
    );
  }

  void _confirmarDespachoACamion(
      BuildContext context, UbicacionEntity contenedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Despacho"),
        content: Text(
            "¿Confirmas la carga al camión del contenedor ${contenedor.serie}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () {
              Navigator.pop(context);
              // Aquí llamas a tu función de despacho real
              vm.registrarMovimientoPisoCamion(contenedor);
            },
            child: const Text("CONFIRMAR DESPACHO"),
          ),
        ],
      ),
    );
  }

// Widget auxiliar para que el diálogo se vea ordenado
  Widget _datoConfirmacion(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$etiqueta ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}

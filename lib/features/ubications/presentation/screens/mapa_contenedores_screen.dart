import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

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
      context.read<UbicacionesMapaViewModel>().cancelarReacomodo();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // 1. Filtramos las ubicaciones de esta área específica
    final ubicacionesDelArea =
        data.ubicaciones.where((u) => u.area == area.nombre).toList();

    if (ubicacionesDelArea.isEmpty) return const SizedBox.shrink();

    // 2. EXTRAEMOS SOLO NÚMEROS DE ESPACIO
    // Usamos int.tryParse para ignorar valores como "A", "B", etc., que se cuelan en el campo espacio
    final espaciosNumeros = ubicacionesDelArea
        .map((u) => u.espacio)
        .where((e) =>
            int.tryParse(e) !=
            null) // <--- ESTO ELIMINA EL ERROR DE LOS 27 NIVELES
        .toSet()
        .toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a) ?? 0;
        final bNum = int.tryParse(b) ?? 0;
        return aNum.compareTo(bNum);
      });

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

                // Filtramos niveles: Deben coincidir ÁREA y ESPACIO
                final nivelesDelEspacio = ubicacionesDelArea
                    .where((u) => u.espacio == numEspacio)
                    .toList()
                  ..sort((a, b) => a.nivel.compareTo(b.nivel));

                bool tieneNivelLibre = nivelesDelEspacio
                    .any((n) => n.estatus.toLowerCase() == 'free');

                // return _buildEspacioCard(
                //     context, area.nombre, numEspacio, nivelesDelEspacio);
                return InkWell(
                  onTap: () {
                    // 1. Si estamos buscando dónde dejar el contenedor (Fase Destino)
                    if (vm.faseReacomodo == FaseReacomodo.destino) {
                      // 2. Verificamos que el espacio que tocó el operador tenga lugar
                      if (tieneNivelLibre) {
                        // 3. Buscamos el primer nivel 'free' en esa columna/espacio
                        final nivelVacio = nivelesDelEspacio.firstWhere(
                            (n) => n.estatus.toLowerCase() == 'free');

                        // 4. GUARDAMOS EL DESTINO EN EL VIEWMODEL
                        vm.ubicacionDestino = nivelVacio;

                        // 5. ¡ESTO ES LO QUE TE FALTA! Disparar el modal de confirmación
                        // Pasamos el contexto, el área donde tocó, el espacio y los niveles para mostrar el resumen
                        _confirmarAterrizajeReacomodo(context, area.nombre,
                            numEspacio, nivelesDelEspacio);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "⚠️ Este espacio está lleno, busca otro.")));
                      }
                    }
                    // 6. Si no estamos en reacomodo, flujo normal (abrir selector de origen)
                    else {
                      _showNivelesSelector(
                          context, area.nombre, numEspacio, nivelesDelEspacio);
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: vm
                        .enModoReacomodo, // Si reacomodamos, ignoramos clics internos de los niveles
                    child: _buildEspacioCard(
                        context, area.nombre, numEspacio, nivelesDelEspacio),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspacioCard(BuildContext context, String areaNom, String espNom,
      List<UbicacionEntity> niveles) {
    // 1. Contamos cuántos niveles están realmente libres
    int desocupados = niveles.where((n) => n.estatus == "Free").length;

    final bool esElObjetivo =
        niveles.any((n) => n.serie == vm.movimientoEnProceso?.serieReal);

    // 2. Determinamos el color de fondo basado en tu nueva regla
    Color bgColor =
        esElObjetivo ? Colors.blue[50]! : vm.getEspacioColor(niveles);

    // 3. Verificamos si este bloque es el que la API nos mandó (Origen/Destino)
    bool esOrigen = niveles.any((n) => n.id == vm.ubicacionOrigen?.id);
    bool esDestino = niveles.any((n) => n.id == vm.ubicacionDestino?.id);

    final bool tieneEspacioLibre =
        niveles.any((n) => n.estatus.toLowerCase() == 'free');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(2),
      // Aplicamos el color de fondo aquí
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          // Si está seleccionado, el borde es fuerte; si no, un gris suave
          color: esElObjetivo
              ? Colors.amber[700]!
              : (esOrigen
                  ? Colors.blue[900]!
                  : (esDestino ? Colors.orange[900]! : Colors.black12)),
          width: (esElObjetivo || esOrigen || esDestino) ? 3.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // 1. Verificamos qué tipo de movimiento traemos desde el ViewModel
          final tipo = vm.movimientoActaul;

          if (tipo == TipoMovimiento.reacomodo) {
            if (tieneEspacioLibre) {
              // Si hay hueco, abrimos el diálogo para confirmar en qué nivel aterrizar
              _confirmarAterrizajeReacomodo(context, areaNom, espNom, niveles);
            } else {
              // Si está lleno, avisamos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Espacio sin niveles disponibles")),
              );
            }
          }

          if (tipo == TipoMovimiento.pisoCamion) {
            // Llamamos al selector de extracción (lo que ya hicimos)
            _showNivelesSelector(context, areaNom, espNom, niveles);
          } else if (tipo == TipoMovimiento.camionPiso) {
            // LLAMAMOS AL NUEVO SELECTOR DE INGRESO
            _showNivelesSelectorCamionPiso(context, areaNom, espNom, niveles);
          } else if (tipo == TipoMovimiento.reacomodo) {
            print('Mandando llamar funcion reacomodo');
            // Llamaremos al de reacomodo (siguiente paso)
            // _showNivelesSelectorReacomodo(context, areaNom, espNom, niveles);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$areaNom-$espNom",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
            const SizedBox(height: 2),
            // Texto descriptivo de capacidad
            Text(
              desocupados == 0 ? "Lleno" : "$desocupados Libres",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: desocupados == 0 ? Colors.red[900] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Mantenemos las bolitas pequeñas para ver la posición exacta
            Wrap(
              spacing: 3,
              children: niveles.take(3).map((n) {
                return Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // La bolita interna sigue marcando ocupado/libre individual
                      color: n.estatus == "Free" ? Colors.green : Colors.red,
                      border: Border.all(color: Colors.white, width: 0.5)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showNivelesSelector(BuildContext context, String area, String esp,
      List<UbicacionEntity> niveles) {
    // 1. Identificamos el contenedor que el sistema mandó a buscar (el objetivo)
    final UbicacionEntity? nivelAsignado =
        niveles.any((n) => n.serie == vm.movimientoEnProceso?.serieReal)
            ? niveles
                .firstWhere((n) => n.serie == vm.movimientoEnProceso?.serieReal)
            : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // --- LÓGICA INTELIGENTE DE SELECCIÓN ---
        UbicacionEntity? proximoMovimiento;
        bool tieneBloqueo = false;

        if (nivelAsignado != null) {
          // Convertimos el nivel asignado a int para comparar
          int nAsignado = int.tryParse(nivelAsignado.nivel.toString()) ?? 0;

          // Buscamos si hay contenedores en niveles superiores (Bloqueadores)
          final bloqueadores = niveles.where((n) {
            int nActual = int.tryParse(n.nivel.toString()) ?? 0;
            return nActual > nAsignado && n.estatus.toLowerCase() != 'free';
          }).toList();

          if (bloqueadores.isNotEmpty) {
            tieneBloqueo = true;
            // Ordenamos para que el "proximo" sea el de nivel más alto (el de hasta arriba)
            bloqueadores.sort((a, b) => (int.tryParse(b.nivel.toString()) ?? 0)
                .compareTo(int.tryParse(a.nivel.toString()) ?? 0));
            proximoMovimiento = bloqueadores.first;
          } else {
            tieneBloqueo = false;
            proximoMovimiento = nivelAsignado;
          }
        }

        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "MOVIMIENTO: PISO - CAMIÓN",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                "Espacio: $area-$esp",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),

              // Banner de Alerta si hay bloqueo
              if (tieneBloqueo)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.priority_high, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "BLOQUEO DETECTADO: Debe despejar el Nivel ${proximoMovimiento?.nivel} primero.",
                          style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Listado de niveles (Invertido para ver el 3 arriba y 1 abajo)
              ...niveles.reversed.map((n) {
                bool esElObjetivo =
                    n.serie == vm.movimientoEnProceso?.serieReal;
                bool esElQueTocaMover = n.serie == proximoMovimiento?.serie;
                bool estaVacio = n.estatus.toLowerCase() == 'free';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color:
                        esElQueTocaMover ? Colors.blue[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: esElQueTocaMover ? Colors.blue : Colors.grey[300]!,
                      width: esElQueTocaMover ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      esElQueTocaMover
                          ? Icons.move_to_inbox
                          : Icons.inventory_2,
                      color: estaVacio
                          ? Colors.grey
                          : (esElQueTocaMover ? Colors.blue : Colors.black87),
                    ),
                    title: Text("Nivel ${n.nivel}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      esElObjetivo
                          ? "Contenedor a mover: ${n.serie}"
                          : (estaVacio ? "Espacio Libre" : "Serie: ${n.serie}"),
                      style: TextStyle(
                          color: esElQueTocaMover
                              ? Colors.blue[700]
                              : Colors.black54,
                          fontWeight: esElQueTocaMover
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                    trailing: esElQueTocaMover
                        ? const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.blue)
                        : null,
                  ),
                );
              }).toList(),

              // BOTÓN INTELIGENTE
              if (proximoMovimiento != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tieneBloqueo
                            ? Colors.orange[800]
                            : Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // La App manda a reacomodar el que detectó como prioritario
                        if (tieneBloqueo) {
                          // --- CASO A: Hay que despejar la pila ---
                          // Manda a la fase de buscar un hueco en el mapa
                          vm.activarReacomodo(proximoMovimiento!);
                        } else {
                          // --- CASO B: El contenedor está libre para salir ---
                          // Aquí disparas tu lógica de Despacho (Piso - Camión)
                          _confirmarDespachoACamion(
                              context, proximoMovimiento!);
                        }
                      },
                      icon: Icon(tieneBloqueo
                          ? Icons.layers_clear
                          : Icons.local_shipping),
                      label: Text(
                        tieneBloqueo
                            ? "Reacomodar Nivel ${proximoMovimiento.nivel}"
                            : "Despachar Contenedor",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  // funcion para mostrar la modal de seleccion camion - piso

  void _showNivelesSelectorCamionPiso(BuildContext context, String area,
      String esp, List<UbicacionEntity> niveles) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "MOVIMIENTO: CAMIÓN - PISO",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                "Seleccione destino para: ${vm.movimientoEnProceso?.serieReal}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              ...niveles.map((n) {
                // Validamos si este nivel específico es apto para recibir el contenedor
                bool esApto = vm.puedeDepositar(n, niveles);
                bool estaOcupado = n.estatus.toLowerCase() == 'used';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: esApto ? Colors.green[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: esApto ? Colors.green : Colors.grey[300]!,
                      width: esApto ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.move_to_inbox,
                        color: esApto ? Colors.green : Colors.grey),
                    title: Text("Nivel ${n.nivel}"),
                    subtitle: Text(
                      estaOcupado
                          ? "OCUPADO (Serie: ${n.serie})"
                          : (esApto
                              ? "LISTO PARA RECIBIR"
                              : "BLOQUEADO: Requiere nivel inferior"),
                      style: TextStyle(
                          color: esApto ? Colors.green[700] : Colors.black54,
                          fontWeight:
                              esApto ? FontWeight.bold : FontWeight.normal),
                    ),
                    // Solo dejamos clickear si es apto (tiene sustento y está libre)
                    enabled: esApto,
                    onTap: () {
                      // Guardamos el destino en el ViewModel
                      vm.seleccionarDestino(n);
                      Navigator.pop(context);

                      // Aquí podrías mostrar un SnackBar o Dialog de confirmación final
                      print(
                          'Destino seleccionado: Area $area, Espacio $esp, Nivel ${n.nivel}');
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

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
            onPressed: () => Navigator.pop(context),
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
              vm.ejecutarDespachoPisoCamion(contenedor);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class ContainersMapScreen extends StatelessWidget {
  final String? serviceId;
  final String? areaDestino;
  final String? espacioDestino;
  final String? nivelDestino;
  final String? codigoUbicacionDestino;
  final String? tipoMovimiento;
  final String? movement_type;

  const ContainersMapScreen({
    super.key,
    required this.serviceId,
    required this.areaDestino,
    required this.espacioDestino,
    required this.nivelDestino,
    this.codigoUbicacionDestino,
    required this.tipoMovimiento,
    required this.movement_type,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UbicacionesViewModel>(context, listen: false);

    String texto;

    if (movement_type == 'Camion-Piso' || movement_type == 'Piso-Camion') {
      texto =
          'Destino: Área $areaDestino, Espacio $espacioDestino, Nivel $nivelDestino';
    } else if (tipoMovimiento == 'Reacomodo') {
      texto = 'Reacomodo de Contenedor';
    } else if (tipoMovimiento == 'Pesaje') {
      texto = 'Pesaje de Contenedor';
    } else {
      texto = 'Sin información de movimiento';
    }

    return FutureBuilder(
      future: viewModel.cargarUbicacionesDesdeApi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Consumer<UbicacionesViewModel>(
          builder: (context, vm, _) {
            final areas = vm.getAreas();

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Mapa de contenedores',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor: Color.fromARGB(255, 33, 150, 91),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (movement_type == 'Camion-Piso' ||
                        movement_type == 'Piso-Camion')
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          leading: const Icon(Icons.edit_location_alt,
                              color: Colors.green, size: 32),
                          title: const Text(
                            'Editar destino',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Área: $areaDestino\nEspacio: $espacioDestino\nNivel: $nivelDestino',
                            style: const TextStyle(fontSize: 17),
                          ),
                          onTap: () => _showEspaciosModal(
                              context, areaDestino ?? '', vm),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.grey),
                        ),
                      ),
                    if (movement_type == 'Reacomodo' ||
                        movement_type == 'Pesaje')
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: Colors.white,
                        child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            leading: const Icon(Icons.edit_location_alt,
                                color: Colors.green, size: 32),
                            title: const Text('Tipo De Movimiento'),
                            subtitle: Text(
                              ' ${movement_type} ',
                              style: const TextStyle(fontSize: 17),
                            ),
                            onTap: null),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: areas.length,
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          final isSelected = area == areaDestino;
                          if (tipoMovimiento != 'Reacomodo' &&
                              tipoMovimiento != 'Pesaje' &&
                              tipoMovimiento != 'Camion-Piso')
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: isSelected
                                    ? Colors.green
                                    : Colors.blueAccent,
                              ),
                              onPressed: () =>
                                  _showEspaciosModal(context, area, vm),
                              child: Text(
                                'Área $area',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
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
      },
    );
  }

  void _showEspaciosModal(
      BuildContext context, String area, UbicacionesViewModel vm) {
    final espacios = vm.getEspaciosPorArea(area);
    final combinaciones = <Map<String, String>>[];

    for (var espacio in espacios) {
      combinaciones.add({'area': area, 'espacio': espacio});
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona Área y Espacio'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 400,
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: combinaciones.length,
              itemBuilder: (context, index) {
                final combo = combinaciones[index];
                final area = combo['area']!;
                final espacio = combo['espacio']!;
                final isSelected =
                    area == areaDestino && espacio == espacioDestino;

                return GestureDetector(
                  onTap: () {
                    if (tipoMovimiento != 'Reacomodo' &&
                        tipoMovimiento != 'Pesaje') {
                      Navigator.pop(context);
                      _showNivelesModal(context, area, espacio, vm);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$area - $espacio',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showNivelesModal(
    BuildContext context,
    String area,
    String espacio,
    UbicacionesViewModel vm,
  ) {
    final niveles = vm.getNivelesPorEspacio(area, espacio).take(3).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Niveles de $espacio'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 250,
            child: ListView.builder(
              itemCount: niveles.length,
              itemBuilder: (context, index) {
                final nivel = niveles[index];
                final isDestinoNivel = area == areaDestino &&
                    espacio == espacioDestino &&
                    nivel == nivelDestino;

                final ubicacionesNivel = vm.getUbicacionesPorAreaEspacioYNivel(
                  area,
                  espacio,
                  nivel,
                );
                final nivelOcupado = ubicacionesNivel.isNotEmpty &&
                    ubicacionesNivel.every((u) => u.estatus == 'Used');

                return ListTile(
                  tileColor: isDestinoNivel
                      ? Colors.green[100]
                      : nivelOcupado
                          ? Colors.red[100]
                          : null,
                  title: Text(
                    'Nivel $nivel',
                    style: TextStyle(
                      fontSize: 16,
                      color: nivelOcupado ? Colors.red : null,
                      fontWeight:
                          isDestinoNivel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isDestinoNivel
                      ? const Icon(Icons.star, color: Colors.green)
                      : nivelOcupado
                          ? const Icon(Icons.block, color: Colors.red)
                          : const Icon(Icons.location_on_outlined),
                  onTap: nivelOcupado
                      ? null // Desactiva si está ocupado
                      : () {
                          if (tipoMovimiento != 'Reacomodo' &&
                              tipoMovimiento != 'Pesaje') {
                            Navigator.pop(context);
                            _showUbicacionesDialog(
                                context, area, espacio, nivel, vm);
                          }
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            )
          ],
        );
      },
    );
  }

  void _showUbicacionesDialog(
    BuildContext context,
    String area,
    String espacio,
    String nivel,
    UbicacionesViewModel vm,
  ) {
    final ubicaciones =
        vm.getUbicacionesPorAreaEspacioYNivel(area, espacio, nivel);
    Ubicacion? ubicacionSeleccionada;
    String? ubication_id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          // 🔁 Para manejar estado dentro del diálogo
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Nivel de prueba $nivel - $espacio'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ubicaciones.length,
                  itemBuilder: (context, index) {
                    final u = ubicaciones[index];
                    final isSelected = u == ubicacionSeleccionada;
                    final color = 'blue';
                    print('ID ID ID ${u.id}');
                    ubication_id = u.id;

                    return ListTile(
                      tileColor: isSelected ? Colors.green[100] : null,
                      leading: CircleAvatar(
                        backgroundColor: _colorFromString(color),
                        radius: 10,
                      ),
                      title: Text(
                        u.codigo,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          ubicacionSeleccionada = u;
                        });
                      },
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (ubicacionSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes seleccionar una ubicación.'),
                        ),
                      );
                      return;
                    }

                    try {
                      await vm.registrarMovimiento(
                        movementType: movement_type ?? '',
                        ubicacionSeleccionada: ubicacionSeleccionada!,
                        ubicationId: ubication_id ?? '',
                        serviceId: serviceId,
                      );
                      Navigator.of(dialogContext).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Registrar movimiento'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUbicacionDetalle(BuildContext context, dynamic u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ubicación ${u.codigo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Color: ${u.color}'),
            // Más detalles si necesitas
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Color _colorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.redAccent;
      case 'gray':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class ContainersMapScreen extends StatelessWidget {
  final String areaDestino;
  final String espacioDestino;
  final String nivelDestino;
  final String status;

  const ContainersMapScreen({
    super.key,
    required this.areaDestino,
    required this.espacioDestino,
    required this.nivelDestino,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UbicacionesViewModel>(context, listen: false);

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
              appBar: AppBar(title: const Text('Mapa de Contenedores')),
              body: Column(
                children: [
                  // Tarjeta con información del destino
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.yellow[100],
                      elevation: 2,
                      child: ListTile(
                        leading:
                            const Icon(Icons.move_up, color: Colors.black87),
                        title: const Text('Movimiento de Contenedor'),
                        subtitle: Text(
                          'Destino: Área: $areaDestino, Espacio: $espacioDestino, Nivel: $nivelDestino, Estatus: $status',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  // Mapa de áreas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                          final isDestino = area == areaDestino;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isDestino
                                    ? const BorderSide(
                                        color: Colors.black, width: 2)
                                    : BorderSide.none,
                              ),
                              backgroundColor:
                                  isDestino ? Colors.orange : Colors.blueAccent,
                            ),
                            onPressed: () {
                              _showEspaciosModal(context, area, vm);
                            },
                            child: Text(
                              'Área $area',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Banner fijo al fondo
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey[50],
                child: Text(
                  'Moviendo contenedor a: Área $areaDestino - Espacio $espacioDestino - Nivel $nivelDestino',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: espacios.length,
          itemBuilder: (context, index) {
            final espacio = espacios[index];
            return ListTile(
              title: Text('Espacio $espacio',
                  style: const TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showNivelesModal(context, area, espacio, vm);
              },
            );
          },
        );
      },
    );
  }

  void _showNivelesModal(BuildContext context, String area, String espacio,
      UbicacionesViewModel vm) {
    final niveles = vm.getNivelesPorEspacio(area, espacio).take(3).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: niveles.length,
          itemBuilder: (context, index) {
            final nivel = niveles[index];
            return ListTile(
              title: Text('Nivel $nivel', style: const TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.location_on_outlined),
              onTap: () {
                Navigator.pop(context);
                _showUbicacionesDialog(context, area, espacio, nivel, vm);
              },
            );
          },
        );
      },
    );
  }

  void _showUbicacionesDialog(BuildContext context, String area, String espacio,
      String nivel, UbicacionesViewModel vm) {
    final ubicaciones =
        vm.getUbicacionesPorAreaEspacioYNivel(area, espacio, nivel);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Nivel $nivel - $espacio'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ubicaciones.length,
            itemBuilder: (context, index) {
              final u = ubicaciones[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _colorFromString(u.color),
                  radius: 10,
                ),
                title: Text(u.codigo),
                onTap: () => _showUbicacionDetalle(dialogContext, u),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          )
        ],
      ),
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
            // Agrega más información si es necesario
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

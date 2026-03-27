import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class MapaEspacioItem extends StatelessWidget {
  final String area;
  final String espacio;
  final List<UbicacionEntity> niveles;
  final VoidCallback onTap;

  const MapaEspacioItem({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel para temas de colores y selección
    final vm = context.watch<UbicacionesMapaViewModel>();

    // 1. Contamos desocupados
    int desocupados = niveles.where((n) => n.estatus == "Free").length;

    // 2. Lógica de colores (la que ya limpiamos en el VM)
    Color bgColor = vm.getEspacioColor(niveles);

    // 3. busca el espacio atraves del numero de serie para resaltarlo en el mapa
    final bool esElObjetivo = niveles.any((n) {
      // Triple check:
      // 1. ¿Es la misma serie?
      // 2. ¿Es el mismo nivel que dice la orden?
      // 3. ¿El área y espacio coinciden con este widget?
      return (n.serie ?? "").trim() ==
              vm.movimientoEnProceso?.serieReal.trim() &&
          n.nivel == vm.movimientoEnProceso?.nivel &&
          area == vm.movimientoEnProceso?.area &&
          espacio == vm.movimientoEnProceso?.espacio;
    });

    final bool esOrigenIdentificado =
        niveles.any((n) => n.id == vm.ubicacionOrigen?.id);

    return Card(
      elevation: (esElObjetivo || esOrigenIdentificado) ? 8 : 2,
      margin: const EdgeInsets.all(2),
      color: (esElObjetivo || esOrigenIdentificado) ? Colors.blue[50] : bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: (esElObjetivo || esOrigenIdentificado)
              ? Colors.amber[700]!
              : Colors.black12,
          width: (esElObjetivo || esOrigenIdentificado) ? 3.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$area-$espacio",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(
              desocupados == 0 ? "Lleno" : "$desocupados Libres",
              style: TextStyle(
                fontSize: 10,
                color: desocupados == 0 ? Colors.red[900] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Las bolitas indicadoras
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: niveles.take(3).map((n) => _buildDot(n)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(UbicacionEntity n) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: n.estatus == "Free" ? Colors.green : Colors.red,
        border: Border.all(color: Colors.white, width: 0.5),
      ),
    );
  }
}

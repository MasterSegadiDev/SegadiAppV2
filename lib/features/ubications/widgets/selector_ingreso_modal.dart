import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class SelectorIngresoModal extends StatelessWidget {
  final String area;
  final String espacio;
  final List<UbicacionEntity> niveles;
  final UbicacionesMapaViewModel vm;

  const SelectorIngresoModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    // Invertimos la lista para que el Nivel 3 aparezca arriba visualmente
    final nivelesOrdenados = niveles.reversed.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tirador visual del modal
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            "MOVIMIENTO: CAMIÓN - PISO",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[600],
                letterSpacing: 1.2,
                fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            "Destino para: ${vm.movimientoEnProceso?.serieReal ?? 'S/N'}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 5),
          Text("Ubicación: $area - $espacio",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Divider(height: 30),

          // Listado de niveles
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nivelesOrdenados.length,
              itemBuilder: (context, index) {
                final n = nivelesOrdenados[index];
                bool esApto = vm.puedeDepositar(n, niveles);
                bool estaOcupado = n.estatus.toLowerCase() == 'used';

                return _buildOpcionNivel(context, n, esApto, estaOcupado);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionNivel(
      BuildContext context, UbicacionEntity n, bool esApto, bool estaOcupado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: esApto ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esApto ? Colors.green[400]! : Colors.grey[300]!,
          width: esApto ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: esApto ? Colors.green : Colors.grey[400],
          child: Text(n.nivel,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text("Nivel ${n.nivel}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          estaOcupado
              ? "OCUPADO (Serie: ${n.serie})"
              : (esApto
                  ? "LISTO PARA RECIBIR"
                  : "BLOQUEADO: Requiere nivel inferior"),
          style: TextStyle(
            fontSize: 12,
            color: esApto ? Colors.green[700] : Colors.red[400],
            fontWeight: esApto ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: esApto
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock_outline, color: Colors.grey),
        enabled: esApto,
        onTap: () {
          vm.seleccionarDestino(n);
          Navigator.pop(context);
          // Opcional: Mostrar diálogo de confirmación final
          _registrarMovimientoCamionPiso(context, n);
        },
      ),
    );
  }

  void _registrarMovimientoCamionPiso(BuildContext context, UbicacionEntity n) {
    // 1. CAPTURA SEGURA DE SERVICIOS
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.blue, // Azul para ingresos (Camión-Piso)
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.unarchive, color: Colors.white),
              SizedBox(width: 10),
              Text("Confirmar Ingreso",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¿Deseas ingresar el contenedor a esta posición?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text("Ubicación Destino: ${n.codigo}"),
            Text("Nivel: ${n.nivel}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx), // Solo cierra este diálogo de alerta
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cierra el Alert

              // Disparamos la API
              bool exito = await vm.registrarMovimientoCamionPiso(n);

              if (exito) {
                // Limpiamos solo tras el éxito
                vm.limpiarEstado();

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        "¡Contenedor ingresado a la posición ${n.codigo}! Regresando..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // Esperamos 3 segundos para que lea el mensaje
                await Future.delayed(const Duration(seconds: 3));

                // Lo sacamos de la pantalla del mapa al listado original
                navigator.pop();
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Error: ${vm.errorMessage}"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child:
                const Text("CONFIRMAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

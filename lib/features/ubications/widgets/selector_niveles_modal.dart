import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class SelectorNivelesModal extends StatelessWidget {
  final String area;
  final String espacio;
  final List<UbicacionEntity> niveles;
  final UbicacionesMapaViewModel vm;

  const SelectorNivelesModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.vm,
  });

  void _mostrarError(BuildContext context, String mensaje) {
    // 1. Cerramos la modal primero para que el SnackBar se vea libre
    Navigator.pop(context);

    // 2. Mostramos el mensaje en el Scaffold principal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior
            .floating, // Esto lo hace flotar con bordes redondeados
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20), // Le da aire respecto a los bordes
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Identificamos el contenedor objetivo de la orden
    final UbicacionEntity? nivelAsignado =
        niveles.any((n) => n.serie == vm.movimientoEnProceso?.serieReal)
            ? niveles
                .firstWhere((n) => n.serie == vm.movimientoEnProceso?.serieReal)
            : null;

    // --- LÓGICA INTELIGENTE DE SELECCIÓN ---
    UbicacionEntity? proximoMovimiento;
    bool tieneBloqueo = false;

    if (vm.movimientoActual == TipoMovimiento.reacomodo) {
      proximoMovimiento = null;
    } else if (nivelAsignado != null) {
      int nAsignado = int.tryParse(nivelAsignado.nivel.toString()) ?? 0;
      final bloqueadores = niveles.where((n) {
        int nActual = int.tryParse(n.nivel.toString()) ?? 0;
        bool estaRealmenteOcupado = n.estatus.trim().toLowerCase() == 'used' &&
            n.serie != null &&
            n.serie!.isNotEmpty;
        return nActual > nAsignado && estaRealmenteOcupado;
      }).toList();

      if (bloqueadores.isNotEmpty) {
        tieneBloqueo = true;
        bloqueadores.sort((a, b) => (int.tryParse(b.nivel.toString()) ?? 0)
            .compareTo(int.tryParse(a.nivel.toString()) ?? 0));
        proximoMovimiento = bloqueadores.first;
      } else {
        proximoMovimiento = nivelAsignado;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tirador visual
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),

          Text("MOVIMIENTO: PISO - CAMIÓN",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12)),
          const SizedBox(height: 8),
          Text("Espacio: $area-$espacio",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 30),

          // Banner de Alerta si hay bloqueo
          if (tieneBloqueo) _buildBannerBloqueo(proximoMovimiento),

          // Listado de niveles (Invertido: 3 arriba, 1 abajo)
          ...niveles.reversed.map((n) {
            bool esElObjetivo = n.serie == vm.movimientoEnProceso?.serieReal;
            bool esElQueTocaMover = n.serie == proximoMovimiento?.serie;
            bool estaVacio = n.estatus.toLowerCase() == 'free';

            // PASAMOS EL CONTEXT AQUÍ 👇
            return _buildItemNivel(
                context, n, esElObjetivo, esElQueTocaMover, estaVacio);
          }),

          const SizedBox(height: 15),

          // BOTÓN DINÁMICO
          if (proximoMovimiento != null)
            _buildBotonAccion(context, tieneBloqueo, proximoMovimiento),
        ],
      ),
    );
  }

  Widget _buildBannerBloqueo(UbicacionEntity? proximo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.priority_high, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "BLOQUEO DETECTADO: Debe despejar el Nivel ${proximo?.nivel} primero para poder sacar el contenedor de abajo.",
              style: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemNivel(
      BuildContext context, // <-- CAMBIO 1: Agregamos el context como parámetro
      UbicacionEntity n,
      bool esObjetivo,
      bool esTocaMover,
      bool estaVacio) {
    return GestureDetector(
      onTap: () {
        // 1. Si el espacio está vacío, no hay nada que reacomodar
        if (estaVacio) {
          _mostrarError(context, "Este nivel está vacío.");
          return;
        }

        // 2. Solo validamos si estamos en modo REACOMODO
        if (vm.movimientoActual == TipoMovimiento.reacomodo) {
          // --- VALIDACIÓN INTELIGENTE ---
          int nivelTocado = int.tryParse(n.nivel.toString()) ?? 0;

          // Revisamos si hay algún contenedor en niveles superiores
          bool tieneContenedorArriba = niveles.any((otro) {
            int nivelOtro = int.tryParse(otro.nivel.toString()) ?? 0;
            return nivelOtro > nivelTocado &&
                otro.estatus.toLowerCase() == 'used';
          });

          if (tieneContenedorArriba) {
            // ❌ BLOQUEO: Hay alguien arriba
            _mostrarError(context,
                "⚠️ No puedes mover el Nivel $nivelTocado porque el nivel superior está ocupado.");
          } else {
            // ✅ ÉXITO: Está despejado, procedemos
            Navigator.pop(context); // Cerramos modal
            vm.activarReacomodo(n); // Iniciamos el flujo de "buscar destino"
          }
        }
      },
      child: Container(
        // ... todo tu código de decoración igual ...
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              esTocaMover ? Colors.blue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: esTocaMover ? Colors.blue[400]! : Colors.grey[300]!,
            width: esTocaMover ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: Icon(
            esTocaMover ? Icons.move_to_inbox : Icons.inventory_2,
            color: estaVacio
                ? Colors.grey
                : (esTocaMover ? Colors.blue : Colors.black54),
          ),
          title: Text("Nivel ${n.nivel}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            esObjetivo
                ? "Contenedor a mover: ${n.serie}"
                : (estaVacio ? "Espacio Libre" : "Serie: ${n.serie}"),
            style: TextStyle(
                color: esTocaMover ? Colors.blue[800] : Colors.black54),
          ),
          trailing: esTocaMover
              ? const Icon(Icons.arrow_forward_ios,
                  size: 12, color: Colors.blue)
              : null,
        ),
      ),
    );
  }

  Widget _buildBotonAccion(
      BuildContext context, bool tieneBloqueo, UbicacionEntity proximo) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              tieneBloqueo ? Colors.orange[800] : Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.pop(context);
          if (tieneBloqueo) {
            // Activa el modo reacomodo y la barra naranja del mapa
            vm.activarReacomodo(proximo);
          } else {
            // Lógica de despacho (puedes llamar a tu función de confirmación)
            _confirmarDespacho(context, proximo, vm);
          }
        },
        icon: Icon(tieneBloqueo ? Icons.layers_clear : Icons.local_shipping),
        label: Text(
          vm.movimientoActual == TipoMovimiento.reacomodo
              ? "Mover Nivel ${proximo.nivel} (Reacomodo)"
              : (tieneBloqueo
                  ? "Despejar Nivel ${proximo.nivel}"
                  : "Confirmar Entrega"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // Mini modal de confirmación para despacho
  void _confirmarDespacho(
      BuildContext context, UbicacionEntity ubi, UbicacionesMapaViewModel vm) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.white),
              SizedBox(width: 10),
              Text("Confirmar Despacho",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Estás seguro de despachar este contenedor?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Serie: ${ubi.serie}",
                style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              navigator.pop();
            },
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              // A) Cerramos todo de una vez para que la UI no se trabe
              Navigator.pop(ctx);
              navigator.pop();

              bool exito = await vm.registrarMovimientoPisoCamion(ubi);

              if (exito) {
                // 4. MOSTRAR MENSAJE DE ÉXITO EN EL MAPA
                messenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                            "Contenedor ${ubi.serie} despachado. Regresando..."),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(
                        seconds: 2), // Un poco menos para no desesperar
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // 5. LA PAUSA DE SEGURIDAD (3 segundos)
                await Future.delayed(const Duration(seconds: 3));

                // 6. SACAR AL USUARIO AL LISTADO
                // Usamos la referencia 'navigator' que guardamos al inicio
                navigator.pop();
              } else {
                // SI HAY ERROR, NO LO SACAMOS (Para que pueda reintentar)
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("Error: ${vm.errorMessage}"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                const Text("CONFIRMAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

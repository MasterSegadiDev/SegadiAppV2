import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';
import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/mapa_movimiento_state.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class SelectorNivelesModal extends StatelessWidget {
  final String area;
  final int espacio;
  final List<UbicacionEntity> niveles;
  final UbicacionesMapaViewModel vm;

  const SelectorNivelesModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final state = vm.state;

    /*
  =========================================================
  MODOS
  =========================================================
  */

    final bool esReacomodo =
        state.paso == PasoMovimiento.seleccionarDestinoReacomodo;

    /*
  =========================================================
  VARIABLES
  =========================================================
  */

    UbicacionEntity? objetivo;

    List<UbicacionEntity> bloqueadores = [];

    bool tieneBloqueadores = false;

    UbicacionEntity? siguienteMovimiento;

    final movimiento = vm.state.ordenActiva;

    /*
  =========================================================
  FLUJO NORMAL PISO -> CAMION
  =========================================================
  */

    if (!esReacomodo) {
      try {
        objetivo = niveles.firstWhere(
          (n) => n.serie == movimiento?.serieObjetivo,
        );

        bloqueadores = vm.validarBloqueadores(
          niveles,
          objetivo,
        );

        tieneBloqueadores = bloqueadores.isNotEmpty;

        siguienteMovimiento = tieneBloqueadores ? bloqueadores.first : objetivo;
      } catch (_) {
        objetivo = null;
        bloqueadores = [];
        tieneBloqueadores = false;
        siguienteMovimiento = null;
      }
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*
          =========================================
          HANDLE
          =========================================
          */

            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(
                bottom: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            /*
          =========================================
          HEADER
          =========================================
          */

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: esReacomodo
                        ? Colors.orange.shade100
                        : tieneBloqueadores
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    esReacomodo
                        ? Icons.move_up
                        : tieneBloqueadores
                            ? Icons.layers_clear
                            : Icons.local_shipping,
                    color: esReacomodo
                        ? Colors.orange.shade800
                        : tieneBloqueadores
                            ? Colors.orange.shade800
                            : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esReacomodo
                            ? 'SELECCIONAR DESTINO'
                            : state.tipoMovimiento ==
                                    TipoMovimiento.reacomodoManual
                                ? 'REACOMODO MANUAL'
                                : 'PISO → CAMIÓN',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Espacio $area-$espacio',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            /*
          =========================================
          ALERTA BLOQUEADORES
          =========================================
          */

            if (!esReacomodo && tieneBloqueadores)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFB74D),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF6C00),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Debe mover primero el nivel ${siguienteMovimiento?.nivel}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /*
          =========================================
          NIVELES
          =========================================
          */

            ...([...niveles]..sort(
                    (a, b) {
                      final nivelA = int.tryParse(a.nivel.toString()) ?? 0;

                      final nivelB = int.tryParse(b.nivel.toString()) ?? 0;

                      return nivelB.compareTo(nivelA);
                    },
                  ))
                .map(
              (nivel) {
                final bool esObjetivo =
                    !esReacomodo && objetivo?.nivel == nivel.nivel;

                final bool esBloqueador = !esReacomodo &&
                    bloqueadores.any(
                      (b) => b.nivel == nivel.nivel,
                    );

                final bool esLibre = nivel.estaLibre;

                return _buildNivelCard(
                  context,
                  nivel,
                  esObjetivo,
                  esBloqueador,
                  esLibre,
                );
              },
            ),
            const SizedBox(height: 22),

            /*
          =========================================
          BOTÓN NORMAL
          =========================================
          */

            if (!esReacomodo && siguienteMovimiento != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tieneBloqueadores
                        ? const Color(0xFFFF8F00)
                        : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    /*
                  =========================================
                  REACOMODO
                  =========================================
                  */

                    if (tieneBloqueadores) {
                      await vm.seleccionarOrigenReacomodo(
                        siguienteMovimiento!,
                      );

                      Navigator.pop(context);

                      avisoReacomodo(context, siguienteMovimiento.nivel,
                          siguienteMovimiento.serie!);

                      return;
                    }

                    /*
                  =========================================
                  CONFIRMAR SALIDA
                  =========================================
                  */

                    _confirmarSalida(
                      context,
                      siguienteMovimiento!,
                    );
                  },
                  icon: Icon(
                    tieneBloqueadores
                        ? Icons.layers_clear
                        : Icons.local_shipping,
                  ),
                  label: Text(
                    tieneBloqueadores
                        ? 'Reacomodar el contenedor del nivel ${siguienteMovimiento.nivel}'
                        : 'Confirmar salida',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  /*
  =========================================================
  CARD NIVEL
  =========================================================
  */

  Widget _buildNivelCard(
    BuildContext context,
    UbicacionEntity nivel,
    bool esObjetivo,
    bool esBloqueador,
    bool esLibre,
  ) {
    Color color = Colors.white;

    if (esObjetivo) {
      color = const Color(0xFFE1F5FE);
    }

    if (esBloqueador) {
      color = const Color(0xFFFFF3E0);
    }

    return GestureDetector(
      onTap: () async {
        final esReacomodo =
            vm.state.tipoMovimiento == TipoMovimiento.pisoCamion ||
                vm.state.tipoMovimiento == TipoMovimiento.reacomodoManual;

        if (!esReacomodo) {
          return;
        }

        if (vm.origenReacomodo == null) {
          debugPrint('ORIGEN REACOMODO NULL');
          return;
        }

        final valido = vm.validarDestinoReacomodo(
          niveles,
          vm.origenReacomodo!,
          nivel,
        );

        if (!valido) {
          mostrarAdvertencia(
            context,
            nivel,
          );

          return;
        }

        await vm.seleccionarDestinoReacomodo(
          nivel,
          niveles,
        );

        if (vm.destinoReacomodo == null) {
          debugPrint('DESTINO REACOMODO NULL');
          return;
        }

        _confirmarReacomodo(
          context,
          nivel,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: esObjetivo
                ? const Color(0xFF00BCD4)
                : esBloqueador
                    ? const Color(0xFFFF8F00)
                    : Colors.grey.shade300,
            width: esObjetivo || esBloqueador ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              esLibre ? Icons.check_circle_outline : Icons.inventory_2_outlined,
              color: esLibre
                  ? Colors.green
                  : esBloqueador
                      ? Colors.orange
                      : Colors.blueGrey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel ${nivel.nivel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esLibre ? 'Espacio libre' : 'Serie: ${nivel.serie}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (esObjetivo)
              const Chip(
                label: Text('Contenedor a mover'),
              ),
            if (esBloqueador)
              const Chip(
                label: Text('Reacomodar contenedor'),
              ),
          ],
        ),
      ),
    );
  }
  /*
  =========================================================
  CONFIRMAR SALIDA
  =========================================================
  */

  void _confirmarSalida(
    BuildContext context,
    UbicacionEntity ubicacion,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            10,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),

          /*
        =========================================
        HEADER
        =========================================
        */

          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirmar salida',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /*
        =========================================
        BODY
        =========================================
        */

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*
            =====================================
            ICONO CENTRAL
            =====================================
            */

              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.outbox_rounded,
                  color: Colors.blue.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              /*
            =====================================
            TEXTO
            =====================================
            */

              const Text(
                '¿Deseas despachar este contenedor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 20),

              /*
            =====================================
            CARD INFO
            =====================================
            */

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      'Serie',
                      ubicacion.serie ?? 'S/N',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      'Ubicación',
                      ubicacion.codigo ?? '',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      'Nivel',
                      ubicacion.nivel.toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /*
        =========================================
        ACTIONS
        =========================================
        */

          actions: [
            Row(
              children: [
                /*
              ===================================
              CANCELAR
              ===================================
              */

                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final exito = await vm.registrarMovimientoPisoCamion(
                        ubicacion,
                      );
                      debugPrint(
                        'RESULTADO PISO CAMION: $exito',
                      );
                      if (context.mounted) {
                        Navigator.pop(
                          context,
                          exito,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'CONFIRMAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

/*
=========================================================
ROW INFO
=========================================================
*/

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmarReacomodo(BuildContext context, UbicacionEntity nivel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets
              .zero, // Quitamos el padding por defecto para el encabezado
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Evita que ocupe toda la pantalla
            children: [
              // Icono sutil de movimiento
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.swap_horiz_rounded,
                    color: Colors.blue, size: 32),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Confirmar reacomodo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 12),

              // Cuerpo del texto con énfasis en la Serie
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black54, height: 1.5),
                  children: [
                    const TextSpan(text: '¿Deseas mover el contenedor\n'),
                    TextSpan(
                      text: '${vm.origenReacomodo?.serie}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Resaltamos el identificador
                        fontSize: 17,
                      ),
                    ),
                    TextSpan(
                        text:
                            '\n al area ${nivel.area} - espacio ${nivel.espacio} - nivel ${nivel.nivel}'),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      vm.destinoReacomodo = null;

                      vm.setPasoMovimiento(
                        PasoMovimiento.seleccionarDestinoReacomodo,
                      );

                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final bottomSheetNavigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );

                      Navigator.pop(context);

                      final exito = await vm.confirmarReacomodo();

                      bottomSheetNavigator.pop(exito);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void mostrarAdvertencia(BuildContext context, UbicacionEntity nivel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // 1. Usamos insetPadding para dar margen externo al diálogo
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            // 2. Definimos un ancho máximo para que no se estire en pantallas grandes
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de advertencia estilizado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Descripción / Mensaje
                  Text(
                    'No puedes colocar el contenedor en este nivel ${nivel.nivel}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Acciones (Botones)
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Tu lógica aquí
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void avisoReacomodo(BuildContext context, int nivel, String serie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // 1. Usamos insetPadding para dar margen externo al diálogo
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            // 2. Definimos un ancho máximo para que no se estire en pantallas grandes
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de advertencia estilizado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_box,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Descripción / Mensaje
                  Text(
                    'Selecciona un espacio y nivel libre para reacomodar el contenedor seleccionado en el nivel ${nivel} con número de serie ${serie}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Acciones (Botones)
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Tu lógica aquí
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

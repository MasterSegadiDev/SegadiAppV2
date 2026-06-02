import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/mapa_movimiento_state.dart';
import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class SelectorReacomodoManualModal extends StatelessWidget {
  final String area;
  final int espacio;
  final List<UbicacionEntity> niveles;
  final UbicacionesMapaViewModel vm;

  const SelectorReacomodoManualModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final state = vm.state;

    final bool seleccionandoOrigen =
        state.paso == PasoMovimiento.seleccionarOrigenManual;

    final bool seleccionandoDestino =
        state.paso == PasoMovimiento.seleccionarDestinoManual;

    final origen = vm.origenManual;

    /*
    =========================================
    ORDENAR NIVELES
    =========================================
    */

    final nivelesOrdenados = [...niveles];

    nivelesOrdenados.sort(
      (a, b) {
        final nivelA = int.tryParse(a.nivel.toString()) ?? 0;

        final nivelB = int.tryParse(b.nivel.toString()) ?? 0;

        return nivelB.compareTo(nivelA);
      },
    );

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
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.indigo.shade800,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REACOMODO MANUAL',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seleccionandoOrigen
                            ? 'Seleccione contenedor origen'
                            : 'Seleccione destino',
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
            const SizedBox(height: 20),

            /*
            =========================================
            ORIGEN SELECCIONADO
            =========================================
            */

            if (origen != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(
                  bottom: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.indigo.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTENEDOR ORIGEN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Serie: ${origen.serie}',
                    ),
                    Text(
                      'Ubicación: ${origen.codigo}',
                    ),
                    Text(
                      'Nivel: ${origen.nivel}',
                    ),
                  ],
                ),
              ),

            /*
            =========================================
            LISTA NIVELES
            =========================================
            */

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: nivelesOrdenados.length,
                itemBuilder: (context, index) {
                  final nivel = nivelesOrdenados[index];

                  final bool estaLibre =
                      nivel.estado.toString().toLowerCase() == 'free';

                  /*
                  =========================================
                  ORIGEN
                  =========================================
                  */

                  final bool esOrigen = origen?.id == nivel.id;

                  /*
                  =========================================
                  ORIGEN VALIDO
                  =========================================
                  */

                  final bool origenValido = !estaLibre &&
                      !vm.tieneContenedoresArriba(
                        niveles,
                        nivel,
                      );

                  /*
                  =========================================
                  DESTINO VALIDO
                  =========================================
                  */

                  bool destinoValido = false;

                  if (seleccionandoDestino && origen != null) {
                    destinoValido = vm.validarDestinoReacomodo(
                      niveles,
                      origen,
                      nivel,
                    );
                  }

                  return _buildNivelCard(
                    context,
                    nivel,
                    estaLibre,
                    esOrigen,
                    origenValido,
                    destinoValido,
                    seleccionandoOrigen,
                    seleccionandoDestino,
                  );
                },
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
    bool estaLibre,
    bool esOrigen,
    bool origenValido,
    bool destinoValido,
    bool seleccionandoOrigen,
    bool seleccionandoDestino,
  ) {
    /*
    =========================================
    ESTILOS BASE
    =========================================
    */

    Color color = Colors.white;

    Color border = Colors.grey.shade300;

    Color texto = Colors.black87;

    IconData icono = Icons.inventory_2_outlined;

    String estado = '';

    /*
    =========================================
    ORIGEN SELECCIONADO
    =========================================
    */

    if (esOrigen) {
      color = Colors.indigo.shade50;

      border = Colors.indigo;

      texto = Colors.indigo.shade900;

      estado = 'ORIGEN SELECCIONADO';

      icono = Icons.move_up;
    }

    /*
    =========================================
    SELECCIONANDO ORIGEN
    =========================================
    */

    else if (seleccionandoOrigen) {
      /*
      =====================================
      ORIGEN VALIDO
      =====================================
      */

      if (origenValido) {
        color = Colors.green.shade50;

        border = Colors.green;

        texto = Colors.green.shade900;

        estado = 'DISPONIBLE PARA MOVER';

        icono = Icons.check_circle;
      }

      /*
      =====================================
      OCUPADO PERO BLOQUEADO
      =====================================
      */

      else if (!estaLibre) {
        color = Colors.red.shade50;

        border = Colors.red.shade300;

        texto = Colors.red.shade900;

        estado = 'TIENE CONTENEDORES ARRIBA';

        icono = Icons.block;
      }

      /*
      =====================================
      LIBRE
      =====================================
      */

      else {
        color = Colors.grey.shade100;

        border = Colors.grey.shade300;

        texto = Colors.grey.shade700;

        estado = 'ESPACIO LIBRE';

        icono = Icons.remove_circle_outline;
      }
    }

    /*
    =========================================
    SELECCIONANDO DESTINO
    =========================================
    */

    else if (seleccionandoDestino) {
      /*
      =====================================
      DESTINO VALIDO
      =====================================
      */

      if (destinoValido) {
        color = Colors.green.shade50;

        border = Colors.green;

        texto = Colors.green.shade900;

        estado = 'DESTINO DISPONIBLE';

        icono = Icons.check_circle;
      }

      /*
      =====================================
      LIBRE PERO INVALIDO
      =====================================
      */

      else if (estaLibre) {
        color = Colors.red.shade50;

        border = Colors.red.shade300;

        texto = Colors.red.shade900;

        estado = 'SIN SOPORTE INFERIOR';

        icono = Icons.block;
      }

      /*
      =====================================
      OCUPADO
      =====================================
      */

      else {
        color = Colors.orange.shade50;

        border = Colors.orange.shade300;

        texto = Colors.orange.shade900;

        estado = 'NIVEL OCUPADO';

        icono = Icons.inventory_2;
      }
    }

    /*
    =========================================
    ESTADO NORMAL
    =========================================
    */

    else {
      if (estaLibre) {
        color = Colors.grey.shade100;

        border = Colors.grey.shade300;

        texto = Colors.grey.shade700;

        estado = 'LIBRE';

        icono = Icons.check_circle_outline;
      } else {
        color = Colors.orange.shade50;

        border = Colors.orange.shade300;

        texto = Colors.orange.shade900;

        estado = 'OCUPADO';

        icono = Icons.inventory_2;
      }
    }

    /*
    =========================================
    CLICK HABILITADO
    =========================================
    */

    final puedeClickOrigen = seleccionandoOrigen && origenValido;

    final puedeClickDestino = seleccionandoDestino && destinoValido;

    final puedeClick = puedeClickOrigen || puedeClickDestino;

    return GestureDetector(
      onTap: !puedeClick
          ? null
          : () async {
              /*
              =====================================
              SELECCIONAR ORIGEN
              =====================================
              */

              if (seleccionandoOrigen) {
                vm.seleccionarOrigenManual(
                  nivel,
                );

                Navigator.pop(context);
                return;
              }

              /*
              =====================================
              SELECCIONAR DESTINO
              =====================================
              */

              if (seleccionandoDestino) {
                vm.seleccionarDestinoManual(
                  nivel,
                  niveles,
                );

                _confirmarMovimiento(
                  context,
                );

                return;
              }
            },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
            width: puedeClick ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: border.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /*
            =====================================
            NIVEL
            =====================================
            */

            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  nivel.nivel.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            /*
            =====================================
            INFO
            =====================================
            */

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIVEL ${nivel.nivel}',
                    style: TextStyle(
                      color: texto,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    estaLibre ? 'Espacio libre' : 'Serie: ${nivel.serie}',
                    style: TextStyle(
                      color: texto.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: border.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: texto,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /*
            =====================================
            ICONO
            =====================================
            */

            Icon(
              icono,
              color: border,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  /*
  =========================================================
  CONFIRMAR
  =========================================================
  */

  void _confirmarMovimiento(
    BuildContext context,
  ) {
    final origen = vm.origenManual;

    final destino = vm.destinoManual;

    if (origen == null || destino == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: EdgeInsets.zero,

          /*
        =========================================
        CONTENEDOR
        =========================================
        */

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*
            =========================================
            HEADER
            =========================================
            */

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3949AB),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CONFIRMAR REACOMODO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.8,
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

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
                  =====================================
                  MENSAJE
                  =====================================
                  */

                    const Text(
                      '¿Deseas mover el contenedor a la nueva ubicación?',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),

                    /*
                  =====================================
                  SERIE
                  =====================================
                  */

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.indigo.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONTENEDOR',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            origen.serie ?? 'SIN SERIE',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    /*
                  =====================================
                  ORIGEN / DESTINO
                  =====================================
                  */

                    Row(
                      children: [
                        /*
                      =================================
                      ORIGEN
                      =================================
                      */

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.upload_rounded,
                                      color: Colors.orange.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ORIGEN',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  origen.codigo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nivel ${origen.nivel}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        /*
                      =================================
                      DESTINO
                      =================================
                      */

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.download_rounded,
                                      color: Colors.green.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DESTINO',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  destino.codigo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nivel ${destino.nivel}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /*
                  =====================================
                  BOTONES
                  =====================================
                  */

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3949AB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();

                              final exito = await vm.confirmarReacomodoManual();

                              if (!context.mounted) return;

                              print('EXITO : ${exito}');

                              Navigator.of(context).pop(exito);
                            },
                            icon: const Icon(
                              Icons.check_circle,
                            ),
                            label: const Text(
                              'CONFIRMAR',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

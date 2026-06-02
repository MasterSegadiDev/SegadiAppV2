import 'package:flutter/material.dart';

import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';

import 'package:segadi/features/ubications/presentation/viewmodels/ubicaciones_mapa_viewmodel.dart';

class SelectorCamionPisoModal extends StatelessWidget {
  final String area;
  final int espacio;
  final List<UbicacionEntity> niveles;
  final UbicacionesMapaViewModel vm;

  const SelectorCamionPisoModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
    required this.vm,
  });

  /*
  =========================================================
  VALIDAR SOPORTE
  =========================================================
  */

  bool _nivelTieneSoporte(
    UbicacionEntity nivelActual,
  ) {
    final nivelNumero = int.tryParse(
          nivelActual.nivel.toString(),
        ) ??
        0;

    /*
    =========================================
    NIVEL 1 SIEMPRE ES VÁLIDO
    =========================================
    */

    if (nivelNumero == 1) {
      return true;
    }

    /*
    =========================================
    BUSCAR NIVEL INFERIOR
    =========================================
    */

    final nivelInferior = niveles.firstWhere(
      (n) => (int.tryParse(n.nivel.toString()) ?? 0) == nivelNumero - 1,
      orElse: () => nivelActual,
    );

    /*
    =========================================
    DEBE ESTAR OCUPADO
    =========================================
    */

    return nivelInferior.estado.toLowerCase() == 'used';
  }

  @override
  Widget build(BuildContext context) {
    final state = vm.state;

    final MovimientoEntity? movimiento = state.ordenActiva;

    /*
    =========================================
    ORDENAR DESC
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

    /*
    =========================================
    CONTAR DISPONIBLES
    =========================================
    */

    final nivelesDisponibles = niveles.where(
      (n) {
        final libre = n.estado.toLowerCase() == 'free';

        final soporte = _nivelTieneSoporte(n);

        return libre && soporte;
      },
    ).length;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 30,
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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'CAMIÓN → PISO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movimiento?.serieObjetivo ?? 'SIN SERIE',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'DESTINO: $area-$espacio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'NIVELES DISPONIBLES: $nivelesDisponibles',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            /*
            =========================================
            ALERTA
            =========================================
            */

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF64B5F6),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF1565C0),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seleccione un nivel disponible',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            /*
            =========================================
            LISTA
            =========================================
            */

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: nivelesOrdenados.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final n = nivelesOrdenados[index];

                  final bool estaLibre = n.estado.toLowerCase() == 'free';

                  final bool tieneSoporte = _nivelTieneSoporte(n);

                  final bool disponible = estaLibre && tieneSoporte;

                  return _buildNivelCard(
                    context,
                    n,
                    disponible,
                    tieneSoporte,
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
  CARD
  =========================================================
  */

  Widget _buildNivelCard(
    BuildContext context,
    UbicacionEntity nivel,
    bool disponible,
    bool tieneSoporte,
  ) {
    Color colorCard;
    Color colorBorder;
    Color colorTexto;

    String estadoTexto;

    IconData icono;

    if (!tieneSoporte) {
      colorCard = Colors.orange.shade50;
      colorBorder = Colors.orange.shade300;
      colorTexto = Colors.orange.shade900;

      estadoTexto = 'NIVEL SUPERIOR BLOQUEADO';

      icono = Icons.warning_amber_rounded;
    } else if (disponible) {
      colorCard = Colors.green.shade50;
      colorBorder = Colors.green.shade400;
      colorTexto = Colors.green.shade900;

      estadoTexto = 'NIVEL LIBRE PARA INGRESAR CONTENEDOR';

      icono = Icons.check_circle;
    } else {
      colorCard = Colors.grey.shade100;
      colorBorder = Colors.grey.shade300;
      colorTexto = Colors.black87;

      estadoTexto = 'NIVEL OCUPADO POR CONTENEDOR : (${nivel.serie ?? 'S/N'})';

      icono = Icons.inventory_2;
    }

    return GestureDetector(
      onTap: disponible
          ? () {
              _confirmarMovimiento(
                context,
                nivel,
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorBorder,
            width: disponible ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colorBorder,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  nivel.nivel.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIVEL ${nivel.nivel}',
                    style: TextStyle(
                      color: colorTexto,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    estadoTexto,
                    style: TextStyle(
                      color: colorTexto,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icono,
              color: colorBorder,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarMovimiento(
    BuildContext context,
    UbicacionEntity destino,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1565C0),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.move_to_inbox_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'CONFIRMAR INGRESO',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vm.state.ordenActiva?.serieObjetivo ??
                                  'SIN SERIE',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              '¿Deseas ingresar el contenedor en esta ubicación?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const SizedBox(height: 18),

                            /*
                    =========================================
                    INFO
                    =========================================
                    */

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.location_on_outlined,
                                    'Ubicación',
                                    destino.codigo,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.layers_outlined,
                                    'Nivel',
                                    destino.nivel.toString(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            /*
                    =========================================
                    BOTONES
                    =========================================
                    */

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
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

                                      final exito = await vm
                                          .registrarMovimientoCamionPiso(
                                        destino,
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
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
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
                ),
              ),
            ));
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

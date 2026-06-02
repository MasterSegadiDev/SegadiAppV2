import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';

class VisualizarEspacioModal extends StatelessWidget {
  final String area;
  final int espacio;
  final List<UbicacionEntity> niveles;

  const VisualizarEspacioModal({
    super.key,
    required this.area,
    required this.espacio,
    required this.niveles,
  });

  @override
  Widget build(BuildContext context) {
    final nivelesOrdenados = [...niveles];

    nivelesOrdenados.sort(
      (a, b) => b.nivel.compareTo(a.nivel),
    );

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
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
              width: 46,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
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
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'CONSULTA DE ESPACIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$area-$espacio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /*
            =========================================
            NIVELES
            =========================================
            */

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: nivelesOrdenados.length,
                itemBuilder: (_, index) {
                  final n = nivelesOrdenados[index];

                  final ocupado = n.estado.toLowerCase() == 'used';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                          ocupado ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ocupado
                            ? Colors.red.shade300
                            : Colors.green.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        /*
                        =========================================
                        NIVEL
                        =========================================
                        */

                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: ocupado
                                ? Colors.red.shade400
                                : Colors.green.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              n.nivel.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        /*
                        =========================================
                        INFO
                        =========================================
                        */

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NIVEL ${n.nivel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ocupado ? 'OCUPADO' : 'DISPONIBLE',
                                style: TextStyle(
                                  color: ocupado
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (ocupado && n.serie != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Serie: ${n.serie}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          ocupado ? Icons.inventory_2 : Icons.check_circle,
                          color: ocupado
                              ? Colors.red.shade400
                              : Colors.green.shade400,
                          size: 30,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

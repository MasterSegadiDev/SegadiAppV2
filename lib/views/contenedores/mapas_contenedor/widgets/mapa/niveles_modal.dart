import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/contenedores/ubicacionesViewModel.dart';

Future<void> showNivelesModal(
  BuildContext context, {
  required String area,
  required String espacio,
  required String tipoMovimiento,
  required String? movementId,
}) async {
  final vm = context.read<UbicacionesViewModel>();

  final niveles = vm
      .getNivelesPorEspacio(area, espacio)
      .where((n) => n.trim().isNotEmpty)
      .toList()
    ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  final nivelesVisual = niveles.reversed.toList();

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Niveles",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (_, animation, __, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final scale = Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      );

      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: Center(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 120,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// CERRAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 26),
                        ),
                      ],
                    ),

                    Text(
                      "Niveles – Área $area / Espacio $espacio",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: nivelesVisual.length,
                        itemBuilder: (_, index) {
                          final nivel = nivelesVisual[index];
                          final ubic = vm.getUbicacion(area, espacio, nivel);

                          final bool disponible = ubic?.numberSerie == null ||
                              ubic!.numberSerie!.isEmpty;

                          Color color = Colors.grey;
                          if (ubic?.color == "green") color = Colors.green;
                          if (ubic?.color == "red") color = Colors.red;
                          if (ubic?.color == "yellow") color = Colors.yellow;

                          return GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: disponible ? Colors.green : color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      nivel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      disponible
                                          ? "Disponible"
                                          : ubic!.numberSerie!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

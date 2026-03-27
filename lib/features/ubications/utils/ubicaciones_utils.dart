import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';

class UbicacionesUtils {
  // Centralizamos el parseo para evitar errores de String/Int
  static int pNivel(dynamic nivel) => int.tryParse(nivel.toString()) ?? 0;

  static bool esExtraccionValida(
      UbicacionEntity tocada, List<UbicacionEntity> niveles) {
    int nTocado = pNivel(tocada.nivel);
    // Un contenedor sale si NO hay nada 'Used' arriba de él
    return !niveles.any(
        (n) => pNivel(n.nivel) > nTocado && n.estatus.toLowerCase() == 'used');
  }

  static bool esDepositoValido(
      UbicacionEntity tocada, List<UbicacionEntity> niveles) {
    if (tocada.estatus.toLowerCase() != 'free') return false;
    int nDeseado = pNivel(tocada.nivel);
    if (nDeseado == 1) return true;
    // Debe tener un contenedor 'Used' justo abajo
    return niveles.any((n) =>
        pNivel(n.nivel) == nDeseado - 1 && n.estatus.toLowerCase() == 'used');
  }

  static UbicacionEntity? obtenerBloqueadorSuperior(
      UbicacionEntity objetivo, List<UbicacionEntity> niveles) {
    int nObjetivo = pNivel(objetivo.nivel);
    final bloqueadores = niveles
        .where((n) =>
            pNivel(n.nivel) > nObjetivo && n.estatus.toLowerCase() != 'free')
        .toList();
    if (bloqueadores.isEmpty) return null;
    // Retornamos el de más arriba (el que la grúa debe quitar primero)
    bloqueadores.sort((a, b) => pNivel(b.nivel).compareTo(pNivel(a.nivel)));
    return bloqueadores.first;
  }
}

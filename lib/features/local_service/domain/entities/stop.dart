import '../enums/parada_accion.dart';
import '../enums/parada_tipo.dart';

class Parada {
  final ParadaTipo tipo;
  final ParadaAccion accion;
  final String domicilio;

  const Parada({
    required this.tipo,
    required this.accion,
    required this.domicilio,
  });
}

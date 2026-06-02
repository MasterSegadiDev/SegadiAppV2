import 'package:segadi/features/ubications/data/models/movimiento_reponse.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';

abstract class RegistroMovimientoRepository {
  Future<MovimientoResponse> registrar(
    MovimientoRegistro movimiento,
  );
}

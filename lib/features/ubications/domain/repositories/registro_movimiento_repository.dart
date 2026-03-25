import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';

abstract class RegistroMovimientoRepository {
  Future<Map<String, dynamic>> registrar(MovimientoRegistro movimiento);
}

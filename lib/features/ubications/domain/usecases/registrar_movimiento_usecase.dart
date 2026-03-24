import 'package:segadi/features/ubications/domain/repositories/ubicaciones_repository.dart';

class RegistrarMovimientoUseCase {
  final UbicacionesRepository repository;

  RegistrarMovimientoUseCase(this.repository);

  Future<bool> execute({
    required int movimientoId,
    required String ubicacionDestinoId,
    String comentarios = "Movimiento desde App",
  }) {
    return repository.registrarMovimiento(
      movimientoId: movimientoId,
      ubicacionDestinoId: ubicacionDestinoId,
      comentarios: comentarios,
    );
  }
}

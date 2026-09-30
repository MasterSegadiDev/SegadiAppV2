import 'package:segadi/features/local_service/domain/entities/stretch.dart';
import 'package:segadi/features/local_service/domain/repositories/stretch_repository.dart';

class GetActiveTramoUseCase {
  final TramoRepository repository;

  GetActiveTramoUseCase(
    this.repository,
  );

  Future<Tramo?> call(
    String operadorId,
  ) {
    return repository.getActiveTramo(
      operadorId,
    );
  }
}

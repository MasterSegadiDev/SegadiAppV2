import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failures.dart';
import 'package:segadi/features/service_detail/domain/repositories/airbag_repository.dart';

class ChangeOperatorStatusAirbagUseCase {
  final AirbagRepository repository;

  ChangeOperatorStatusAirbagUseCase(this.repository);

  Future<Either<Failure, bool>> execute(String status) {
    return repository.changeOperatorStatus(status: status);
  }
}

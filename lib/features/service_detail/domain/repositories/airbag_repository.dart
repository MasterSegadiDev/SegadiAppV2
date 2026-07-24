import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failure.dart';

abstract class AirbagRepository {
  Future<Either<Failure, bool>> changeOperatorStatus({
    required String status,
  });
}

import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/features/travel_expenses/domain/repositories/travel_expenses_repository.dart';

class GetEvidenceImageUseCase {
  final TravelExpensesRepository repository;

  GetEvidenceImageUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call(String conceptId) async {
    return await repository.getEvidenceImage(conceptId);
  }
}

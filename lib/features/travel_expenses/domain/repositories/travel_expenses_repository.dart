import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';

import '../../../../core/errors/failures.dart';

abstract class TravelExpensesRepository {
  Future<Either<Failure, List<TravelExpenseEntity>>> getAvailableConcepts(
      int serviceId);
  Future<Either<Failure, List<TableExpenseEntity>>> getRegisteredExpenses(
      int serviceId);
  Future<Either<Failure, bool>> insertExpense({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String? comments,
    String? base64Image,
  });
  Future<Either<Failure, Uint8List>> getEvidenceImage(String conceptId);
}

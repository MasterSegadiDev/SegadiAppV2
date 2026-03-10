import 'package:dartz/dartz.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/repositories/travel_expenses_repository.dart';

import '../../../../core/errors/failures.dart';

class GetAvailableConceptsUseCase {
  final TravelExpensesRepository repository;
  GetAvailableConceptsUseCase(this.repository);

  Future<Either<Failure, List<TravelExpenseEntity>>> call(int serviceId) {
    return repository.getAvailableConcepts(serviceId);
  }
}

class GetRegisteredExpensesUseCase {
  final TravelExpensesRepository repository;
  GetRegisteredExpensesUseCase(this.repository);

  Future<Either<Failure, List<TableExpenseEntity>>> call(int serviceId) {
    return repository.getRegisteredExpenses(serviceId);
  }
}

class InsertExpenseUseCase {
  final TravelExpensesRepository repository;
  InsertExpenseUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String comments,
    String? base64Image,
  }) {
    return repository.insertExpense(
      serviceId: serviceId,
      conceptId: conceptId,
      amount: amount,
      comments: comments,
      base64Image: base64Image,
    );
  }
}

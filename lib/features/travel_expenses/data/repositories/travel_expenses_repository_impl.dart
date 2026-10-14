import '../../domain/entities/travel_expense_concept.dart';
import '../../domain/repositories/travel_expenses_repository.dart';
import '../datasources/travel_expenses_remote_datasource.dart';

class TravelExpensesRepositoryImpl implements TravelExpensesRepository {
  final TravelExpensesRemoteDataSource remoteDataSource;

  TravelExpensesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TravelExpenseConcept>> getByReferral({
    required String referralId,
  }) {
    return remoteDataSource.getConcepts(
      referralId,
    );
  }

  @override
  Future<void> registerExpense({
    required String referralId,
    required String travelExpenseId,
    required double amount,
    required String evidencePath,
  }) {
    return remoteDataSource.registerExpense(
      referralId: referralId,
      travelExpenseId: travelExpenseId,
      amount: amount,
      evidencePath: evidencePath,
    );
  }
}

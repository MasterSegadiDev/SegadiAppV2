import '../entities/travel_expense_concept.dart';

abstract class TravelExpensesRepository {
  Future<List<TravelExpenseConcept>> getByReferral({
    required String referralId,
  });

  Future<void> registerExpense({
    required String referralId,
    required String travelExpenseId,
    required double amount,
    required String evidencePath,
  });
}

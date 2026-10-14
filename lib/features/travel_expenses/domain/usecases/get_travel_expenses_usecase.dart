import '../entities/travel_expense_concept.dart';
import '../repositories/travel_expenses_repository.dart';

class GetTravelExpensesUseCase {
  const GetTravelExpensesUseCase(this.repository);
  final TravelExpensesRepository repository;

  Future<List<TravelExpenseConcept>> call(String referralId) {
    if (referralId.trim().isEmpty) {
      throw ArgumentError('El ID de remisión es obligatorio.');
    }
    return repository.getByReferral(referralId: referralId);
  }
}

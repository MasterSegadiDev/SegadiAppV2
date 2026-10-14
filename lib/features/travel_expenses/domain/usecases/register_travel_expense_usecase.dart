import '../repositories/travel_expenses_repository.dart';

class RegisterTravelExpenseUseCase {
  final TravelExpensesRepository repository;

  const RegisterTravelExpenseUseCase(this.repository);

  Future<void> call({
    required String referralId,
    required String travelExpenseId,
    required double amount,
    required double authorizedAmount,
    required String evidencePath,
  }) async {
    if (referralId.trim().isEmpty || travelExpenseId.trim().isEmpty) {
      throw ArgumentError(
        'Faltan identificadores del viático.',
      );
    }

    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError(
        'Ingresa un importe válido mayor a cero.',
      );
    }

    if (amount > authorizedAmount) {
      throw ArgumentError(
        'El importe utilizado no puede superar '
        'el importe autorizado.',
      );
    }

    if (evidencePath.trim().isEmpty) {
      throw ArgumentError(
        'La fotografía es obligatoria.',
      );
    }

    await repository.registerExpense(
      referralId: referralId,
      travelExpenseId: travelExpenseId,
      amount: amount,
      evidencePath: evidencePath,
    );
  }
}

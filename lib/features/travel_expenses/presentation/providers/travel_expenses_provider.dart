import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/travel_expenses_remote_datasource.dart';
import '../../data/repositories/travel_expenses_repository_impl.dart';

import '../../domain/entities/travel_expense_concept.dart';
import '../../domain/repositories/travel_expenses_repository.dart';

import '../../domain/usecases/get_travel_expenses_usecase.dart';
import '../../domain/usecases/register_travel_expense_usecase.dart';

// ==========================================
// DATA SOURCE
// ==========================================

final travelExpensesRemoteDataSourceProvider =
    Provider<TravelExpensesRemoteDataSource>((ref) {
  return TravelExpensesRemoteDataSource();
});

// ==========================================
// REPOSITORY
// ==========================================

final travelExpensesRepositoryProvider =
    Provider<TravelExpensesRepository>((ref) {
  return TravelExpensesRepositoryImpl(
    remoteDataSource: ref.watch(
      travelExpensesRemoteDataSourceProvider,
    ),
  );
});

// ==========================================
// USE CASE - GET
// ==========================================

final getTravelExpensesUseCaseProvider =
    Provider<GetTravelExpensesUseCase>((ref) {
  return GetTravelExpensesUseCase(
    ref.watch(travelExpensesRepositoryProvider),
  );
});

// ==========================================
// USE CASE - POST
// ==========================================

final registerTravelExpenseUseCaseProvider =
    Provider<RegisterTravelExpenseUseCase>((ref) {
  return RegisterTravelExpenseUseCase(
    ref.watch(travelExpensesRepositoryProvider),
  );
});

// ==========================================
// GET - LISTADO DE VIÁTICOS
// ==========================================

final travelExpenseConceptsProvider =
    FutureProvider.family<List<TravelExpenseConcept>, String>(
  (ref, referralId) async {
    final useCase = ref.watch(
      getTravelExpensesUseCaseProvider,
    );

    return useCase.call(
      referralId,
    );
  },
);

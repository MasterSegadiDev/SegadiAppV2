import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/features/travel_expenses/core/errors/travel_expenses_failure.dart';
import 'package:segadi/features/travel_expenses/data/datasources/travel_expenses_remote_datasource.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';
import 'dart:typed_data';

import 'package:segadi/features/travel_expenses/domain/repositories/travel_expenses_repository.dart';

import '../../../../core/errors/failures.dart';

class TravelExpensesRepositoryImpl implements TravelExpensesRepository {
  final TravelExpensesRemoteDataSource remoteDataSource;

  TravelExpensesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TravelExpenseEntity>>> getAvailableConcepts(
      int serviceId) async {
    try {
      final models = await remoteDataSource.getConcepts(serviceId);
      return Right(models);
    } on DioException catch (e) {
      // Usamos el manejador propio de la feature
      final failure = TravelExpensesFailure.fromDioError(e);
      return Left(ServerFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al obtener conceptos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TableExpenseEntity>>> getRegisteredExpenses(
      int serviceId) async {
    try {
      final models = await remoteDataSource.getRegisteredExpenses(serviceId);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> insertExpense({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String comments,
    String? base64Image,
  }) async {
    try {
      final success = await remoteDataSource.insertExpense(
        serviceId: serviceId,
        conceptId: conceptId,
        amount: amount,
        comments: comments,
        image: base64Image,
      );
      return Right(success);
    } on DioException catch (e) {
      // AQUÍ es donde capturamos el mensaje de "Revisar importe"
      final failure = TravelExpensesFailure.fromDioError(e);
      return Left(ServerFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Error al guardar el gasto: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getEvidenceImage(String conceptId) async {
    try {
      // Agrega este print para ver si el ID llega al repo
      print("Repo: Solicitando imagen para ID $conceptId");
      final result = await remoteDataSource.fetchImage(conceptId);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("Error en el repositorio al obtener imagen"));
    }
  }
}

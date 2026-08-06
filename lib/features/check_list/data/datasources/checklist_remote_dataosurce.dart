import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/features/check_list/data/dto/checklist_dto.dart';

import '../../../../core/network/dio_client.dart';

abstract class ChecklistRemoteDatasource {
  Future<ChecklistDto> getChecklist(
    String referralId,
  );

  Future<bool> sendChecklist(
    ChecklistDto checklist,
  );
}

class ChecklistRemoteDatasourceImpl implements ChecklistRemoteDatasource {
  ChecklistRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<ChecklistDto> getChecklist(
    String referralId,
  ) async {
    try {
      final response = await _dio.get(
        '/appUser/checklist/$referralId',
      );

      debugPrint(response.data.toString());

      final List<dynamic> result = response.data['Result'] ?? [];

      if (result.isEmpty) {
        throw Exception(
          'No existe checklist para esta remisión.',
        );
      }

      return ChecklistDto.fromJson(
        result.first as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<bool> sendChecklist(
    ChecklistDto checklist,
  ) async {
    try {
      await _dio.put(
        '/appUser/checklist',
        data: checklist.toJson(),
      );

      return true;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}

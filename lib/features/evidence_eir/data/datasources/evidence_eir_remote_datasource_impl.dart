import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/evidence_eir/data/datasources/evidence_eir_remote_datasource.dart';
import 'package:segadi/features/evidence_eir/data/models/delivery_evidence_eir_model.dart';

class EvidenceEirRemoteDatasourceImpl extends EvidenceEirRemoteDatasource {
  EvidenceEirRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<bool> sendDeliveryEvidencesEir(
    DeliveryEvidenceEirModel params,
  ) async {
    final Map<String, dynamic> mapData = {
      'notes': params.notes,
      'referral_id': params.referralId,
    };

    if (params.evidence1 != null) {
      mapData['evidence_1'] = await MultipartFile.fromFile(
        params.evidence1!.path,
      );
    }

    if (params.evidence2 != null) {
      mapData['evidence_2'] = await MultipartFile.fromFile(
        params.evidence2!.path,
      );
    }

    if (params.evidence3 != null) {
      mapData['evidence_3'] = await MultipartFile.fromFile(
        params.evidence3!.path,
      );
    }

    if (params.evidence4 != null) {
      mapData['evidence_4'] = await MultipartFile.fromFile(
        params.evidence4!.path,
      );
    }

    if (params.evidence5 != null) {
      mapData['evidence_5'] = await MultipartFile.fromFile(
        params.evidence5!.path,
      );
    }

    final formData = FormData.fromMap(mapData);

    final response = await _dio.post(
      '/appUser/referral/${params.serviceRequestId}/eir-evidence',
      data: formData,
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al subir evidencias.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudieron subir las evidencias.',
      );
    }

    return true;
  }
}

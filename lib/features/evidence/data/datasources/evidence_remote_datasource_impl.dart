import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence/data/models/delivery_confirmation_model.dart';
import 'package:segadi/features/evidence/data/models/delivery_evidence_model.dart';

class EvidenceRemoteDatasourceImpl extends EvidenceRemoteDatasource {
  EvidenceRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<bool> sendDeliveryConfirmation(
    DeliveryConfirmationModel confirmation,
  ) async {
    final formData = FormData.fromMap({
      'fileSignature': MultipartFile.fromBytes(
        confirmation.fileSignature,
        filename: 'signature.png',
      ),
      'strDateTime': confirmation.strDateTime,
      'strReceiverName': confirmation.strReceiverName,
    });

    final response = await _dio.post(
      '/appUser/referral/${confirmation.serviceRequestId}/delivery-signature',
      data: formData,
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al enviar la firma.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo confirmar la entrega.',
      );
    }

    return true;
  }

  @override
  Future<bool> sendDeliveryEvidences(
    DeliveryEvidenceModel params,
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
      '/appUser/referral/${params.serviceRequestId}/delivery-evidence',
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

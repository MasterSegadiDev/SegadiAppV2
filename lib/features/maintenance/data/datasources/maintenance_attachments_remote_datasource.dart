import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/core/network/fracttal_api_client.dart';

class MaintenanceAttachmentsRemoteDataSource {
  MaintenanceAttachmentsRemoteDataSource(
    this._client,
  );

  final FracttalApiClient _client;
  final Dio _storageDio = Dio();

  Future<List<String>> uploadImages(
    List<XFile> images,
  ) async {
    final keys = <String>[];

    for (final image in images) {
      final size = await image.length();

      if (size <= 0 || size > 100490000) {
        throw ArgumentError(
          'La imagen ${image.name} tiene '
          'un tamaño no permitido.',
        );
      }

      final response = await _client.request(
        's3_object/',
        method: 'POST',
        data: {
          'name': image.name,
          'size': size,
        },
      );

      final body = response.data;

      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        throw Exception(
          'Error al obtener credenciales: $body',
        );
      }

      final credentials = body['data'] as Map;

      String requiredValue(String field) {
        final value = credentials[field];

        if (value is! String || value.isEmpty) {
          throw FormatException(
            'Falta $field en credenciales S3.',
          );
        }

        return value;
      }

      final key = requiredValue('key');
      final host = requiredValue('host');

      final form = FormData();

      form.fields.addAll([
        MapEntry('key', key),
        MapEntry('acl', requiredValue('acl')),
        MapEntry('policy', requiredValue('policy')),
        MapEntry(
          'x-amz-credential',
          requiredValue('credential'),
        ),
        const MapEntry(
          'x-amz-algorithm',
          'AWS4-HMAC-SHA256',
        ),
        MapEntry(
          'x-amz-date',
          requiredValue('date'),
        ),
        MapEntry(
          'x-amz-signature',
          requiredValue('signature'),
        ),
        const MapEntry(
          'success_action_status',
          '200',
        ),
      ]);

      // El archivo debe ser el último campo.
      form.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
        ),
      );

      // No usar el token de Fracttal en S3.
      await _storageDio.post(
        host,
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      keys.add(key);
    }

    return keys;
  }

  Future<void> attachImages({
    required int requestIdCode,
    required int statusId,
    required List<String> keys,
  }) async {
    if (keys.isEmpty) {
      throw ArgumentError(
        'No hay fotografías para asociar.',
      );
    }

    if (!{1, 2, 4}.contains(statusId)) {
      throw StateError(
        'El estado $statusId de la solicitud '
        'no admite adjuntos en Fracttal.',
      );
    }

    final response = await _client.request(
      'work_requests_attachments_files/$requestIdCode',
      method: 'POST',
      data: {
        'id_status': statusId,
        'paths': keys.map((key) {
          return {
            'name': key,
            'description': 'Evidencia fotográfica',
          };
        }).toList(),
      },
    );

    final body = response.data;

    if (body is! Map || body['success'] != true) {
      throw Exception(
        'Error al asociar fotografías: $body',
      );
    }
  }
}

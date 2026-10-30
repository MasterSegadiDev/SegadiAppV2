import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/core/network/fracttal_api_client.dart';

class MaintenanceAttachmentsRemoteDataSource {
  MaintenanceAttachmentsRemoteDataSource(
    this._client,
  );

  final FracttalApiClient _client;
  final Dio _storageDio = Dio();

  Future<List<String>> uploadImages(List<XFile> photos) async {
    final uploadedKeys = <String>[];

    for (final photo in photos) {
      final bytes = await photo.readAsBytes();

      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${photo.name}';

      // 1. Obtener credenciales de Fracttal.
      final response = await _client.request(
        's3_object/',
        method: 'POST',
        data: {
          'name': fileName,
          'size': bytes.length,
        },
      );

      // El cliente puede devolver Response de Dio
      // o directamente el JSON.
      final Object? responseData = response.data;

      if (responseData is! Map) {
        throw StateError(
          'Respuesta inesperada de Fracttal: '
          '${responseData.runtimeType}',
        );
      }

      final responseMap = Map<String, dynamic>.from(responseData);

      debugPrint(
        '[S3] Campos principales: ${responseMap.keys.toList()}',
      );

      // 2. Extraer data sin asumir que siempre es un Map.
      final Object? data = responseMap['data'];

      Map<String, dynamic> credentials;

      if (data is Map) {
        credentials = Map<String, dynamic>.from(data);
      } else if (data is List && data.isNotEmpty && data.first is Map) {
        credentials = Map<String, dynamic>.from(data.first as Map);
      } else if (responseMap.containsKey('key')) {
        credentials = responseMap;
      } else {
        throw StateError(
          'Estructura de credenciales no reconocida. '
          'Tipo de data: ${data.runtimeType}. '
          'Campos disponibles: ${responseMap.keys.toList()}',
        );
      }

      debugPrint(
        '[S3] Campos de credenciales: '
        '${credentials.keys.toList()}',
      );

      String requiredField(String field) {
        final value = credentials[field]?.toString();

        if (value == null || value.trim().isEmpty) {
          throw StateError(
            'Fracttal no devolvió el campo $field. '
            'Campos disponibles: ${credentials.keys.toList()}',
          );
        }

        return value;
      }

      // 3. Preparar URL de Amazon S3.
      final host = requiredField('host');
      final bucket = requiredField('bucket');
      final key = requiredField('key');

      final normalizedHost =
          host.startsWith('http://') || host.startsWith('https://')
              ? host
              : 'https://$host';

      final hostUri = Uri.parse(normalizedHost);

      if (!hostUri.hasAuthority) {
        throw StateError('Host S3 inválido: $host');
      }

      final String uploadUrl;

      if (hostUri.host == bucket || hostUri.host.startsWith('$bucket.')) {
        uploadUrl = hostUri.toString();
      } else if (hostUri.host.startsWith('s3.') ||
          hostUri.host == 's3.amazonaws.com') {
        final basePath = hostUri.path.replaceFirst(RegExp(r'/$'), '');

        uploadUrl = hostUri
            .replace(
              path: '$basePath/$bucket',
            )
            .toString();
      } else {
        uploadUrl = hostUri.toString();
      }

      // 4. Preparar formulario multipart.
      final form = FormData();

      form.fields.addAll([
        MapEntry('key', key),
        MapEntry('acl', requiredField('acl')),
        MapEntry('policy', requiredField('policy')),
        MapEntry(
          'x-amz-credential',
          requiredField('credential'),
        ),
        const MapEntry(
          'x-amz-algorithm',
          'AWS4-HMAC-SHA256',
        ),
        MapEntry('x-amz-date', requiredField('date')),
        MapEntry(
          'x-amz-signature',
          requiredField('signature'),
        ),
        const MapEntry('success_action_status', '200'),
      ]);

      // El archivo debe ir al final.
      form.files.add(
        MapEntry(
          'file',
          MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        ),
      );

      // 5. Subir a S3 sin token de Fracttal.
      final s3Dio = Dio();

      try {
        debugPrint('[S3] Subiendo archivo a: $uploadUrl');

        final uploadResponse = await s3Dio.post(
          uploadUrl,
          data: form,
          options: Options(
            contentType: Headers.multipartFormDataContentType,
            followRedirects: false,
          ),
        );

        debugPrint(
          '[S3] Archivo subido. '
          'HTTP ${uploadResponse.statusCode}',
        );

        uploadedKeys.add(key);
      } on DioException catch (error) {
        debugPrint(
          '[S3] URL: ${error.requestOptions.uri}',
        );
        debugPrint(
          '[S3] Método: ${error.requestOptions.method}',
        );
        debugPrint(
          '[S3] HTTP: ${error.response?.statusCode}',
        );
        debugPrint(
          '[S3] Respuesta: ${error.response?.data}',
        );

        rethrow;
      }
    }

    return uploadedKeys;
  }

  Future<void> attachImages({
    required int requestIdCode,
    required int statusId,
    required List<String> keys,
  }) async {
    await _client.request(
      'work_requests_attachments_files/$requestIdCode',
      method: 'POST',
      data: {
        'id_status': statusId,
        'paths': keys
            .map((key) => {
                  'name': key,
                  'description': 'Evidencia de mantenimiento',
                })
            .toList(),
      },
    );

    debugPrint(
      '[Fracttal] Adjuntos asociados a solicitud $requestIdCode',
    );
  }

  String _resolveS3Url({
    required String host,
    required String bucket,
  }) {
    final rawHost = host.trim();

    if (rawHost.isEmpty) {
      throw StateError('Fracttal devolvió host vacío');
    }

    final uri = Uri.parse(
      rawHost.startsWith('http://') || rawHost.startsWith('https://')
          ? rawHost
          : 'https://$rawHost',
    );

    if (!uri.hasAuthority) {
      throw StateError('Host S3 inválido: $rawHost');
    }

    // Si el host ya identifica al bucket, conservarlo.
    if (uri.host == bucket || uri.host.startsWith('$bucket.')) {
      return uri.toString();
    }

    // Si Fracttal devuelve un endpoint regional genérico,
    // usar el bucket como parte de la ruta.
    if (uri.host.startsWith('s3.') || uri.host == 's3.amazonaws.com') {
      final path = uri.path.replaceAll(RegExp(r'/$'), '');

      return uri
          .replace(
            path: '$path/$bucket',
          )
          .toString();
    }

    // Otros hosts: no modificar la ruta firmada.
    return uri.toString();
  }
}

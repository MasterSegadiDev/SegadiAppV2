import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/maintenance_requests_remote_datasource.dart';
import '../../data/datasources/maintenance_attachments_remote_datasource.dart';
import '../../data/models/create_maintenance_request_model.dart';

class MaintenanceReportResult {
  const MaintenanceReportResult({
    required this.createdId,
    required this.idCode,
    required this.identifier,
    required this.photosCount,
  });

  final int createdId;
  final int idCode;
  final String identifier;
  final int photosCount;
}

class CreateMaintenanceReportUseCase {
  CreateMaintenanceReportUseCase(
    this._requests,
    this._attachments,
  );

  final MaintenanceRequestsRemoteDataSource _requests;
  final MaintenanceAttachmentsRemoteDataSource _attachments;

  final Map<String, CreatedMaintenanceRequest> _createdRequests = {};

  final Map<String, List<String>> _uploadedKeys = {};

  Future<MaintenanceReportResult> call(
    CreateMaintenanceRequestModel request, {
    required List<XFile> photos,
  }) async {
    if (photos.isEmpty) {
      throw ArgumentError(
        'Agrega al menos una fotografía.',
      );
    }

    debugPrint('[1] Creando solicitud');
    // No crear dos veces la misma solicitud.
    var created = _createdRequests[request.identifier];

    if (created == null) {
      created = await _requests.createRequest(request);
      debugPrint('[2] Solicitud creada: ${created.id}');
      _createdRequests[request.identifier] = created;
    }

    // Obtener id_code y estado desde Fracttal.
    final detail = await _requests.findCreatedRequest(
      identifier: request.identifier,
    );

    debugPrint('[3] id_code obtenido: ${detail.idCode}');

    // Si las imágenes ya se subieron a S3,
    // reutilizar sus keys.
    var keys = _uploadedKeys[request.identifier];

    if (keys == null) {
      keys = await _attachments.uploadImages(photos);
      debugPrint('[4] Fotografías subidas: ${keys.length}');
      _uploadedKeys[request.identifier] = keys;
    }

    await _attachments.attachImages(
      requestIdCode: detail.idCode,
      statusId: detail.statusId,
      keys: keys,
    );
    debugPrint('[5] Fotografías asociadas correctamente');

    _createdRequests.remove(request.identifier);
    _uploadedKeys.remove(request.identifier);

    return MaintenanceReportResult(
      createdId: created.id,
      idCode: detail.idCode,
      identifier: request.identifier,
      photosCount: photos.length,
    );
  }
}

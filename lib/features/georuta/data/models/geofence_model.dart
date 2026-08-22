import '../../domain/entities/geofence_entity.dart';

class GeofenceModel extends GeofenceEntity {
  const GeofenceModel({
    required super.serviceRequestId,
    required super.serviceStatus,
    super.wialonGeofenceLineId,
    required super.wialonGeofenceLineName,
    super.wialonOriginCircleId,
    required super.wialonOriginCircleName,
    super.wialonDestinationCircleId,
    required super.wialonDestinationCircleName,
    super.destinationLat,
    super.destinationLng,
  });

  factory GeofenceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeofenceModel(
      serviceRequestId: json['strServiceRequestId']?.toString() ?? '',
      serviceStatus: _toInt(json['intServiceStatus']) ?? 0,
      wialonGeofenceLineId: _toInt(json['intWialonGeofenceLineId']),
      wialonGeofenceLineName:
          json['strWialonGeofenceLineName']?.toString() ?? '',
      wialonOriginCircleId: _toInt(json['intWialonOriginCircleId']),
      wialonOriginCircleName:
          json['strWialonOriginCircleName']?.toString() ?? '',
      wialonDestinationCircleId: _toInt(json['intWialonDestinationCircleId']),
      wialonDestinationCircleName:
          json['strWialonDestinationCircleName']?.toString() ?? '',
      destinationLat: _toDouble(json['fltDestinationLat']),
      destinationLng: _toDouble(json['fltDestinationLng']),
    );
  }

  static int? _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}

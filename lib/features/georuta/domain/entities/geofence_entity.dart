class GeofenceEntity {
  final String serviceRequestId;
  final int serviceStatus;

  final int? wialonGeofenceLineId;
  final String wialonGeofenceLineName;

  final int? wialonOriginCircleId;
  final String wialonOriginCircleName;

  final int? wialonDestinationCircleId;
  final String wialonDestinationCircleName;

  final double? destinationLat;
  final double? destinationLng;

  const GeofenceEntity({
    required this.serviceRequestId,
    required this.serviceStatus,
    this.wialonGeofenceLineId,
    required this.wialonGeofenceLineName,
    this.wialonOriginCircleId,
    required this.wialonOriginCircleName,
    this.wialonDestinationCircleId,
    required this.wialonDestinationCircleName,
    this.destinationLat,
    this.destinationLng,
  });
}

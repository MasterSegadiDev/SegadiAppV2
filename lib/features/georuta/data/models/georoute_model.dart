class GeorouteModel {
  final String serviceRequestId;
  final int serviceStatus;
  final GeoroutePointModel origin;
  final GeoroutePointModel destination;
  final GeorouteRouteModel route;

  const GeorouteModel({
    required this.serviceRequestId,
    required this.serviceStatus,
    required this.origin,
    required this.destination,
    required this.route,
  });

  factory GeorouteModel.fromJson(Map<String, dynamic> json) {
    return GeorouteModel(
      serviceRequestId: json['strServiceRequestId']?.toString() ?? '',
      serviceStatus: (json['intServiceStatus'] as num?)?.toInt() ?? 0,
      origin: GeoroutePointModel.fromJson(
        json['origin'] as Map<String, dynamic>,
      ),
      destination: GeoroutePointModel.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      route: GeorouteRouteModel.fromJson(
        json['route'] as Map<String, dynamic>,
      ),
    );
  }
}

class GeoroutePointModel {
  final int id;
  final double? latitude;
  final double? longitude;
  final String name;

  const GeoroutePointModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory GeoroutePointModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeoroutePointModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      name: json['name']?.toString() ?? '',
    );
  }
}

class GeorouteRouteModel {
  final int id;
  final String name;
  final List<GeorouteCoordinateModel> coordinates;

  const GeorouteRouteModel({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  factory GeorouteRouteModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final coordinatesJson = json['coordinates'] as List<dynamic>? ?? [];

    return GeorouteRouteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      coordinates: coordinatesJson
          .whereType<Map<String, dynamic>>()
          .map(
            GeorouteCoordinateModel.fromJson,
          )
          .toList(),
    );
  }
}

class GeorouteCoordinateModel {
  final double latitude;
  final double longitude;

  const GeorouteCoordinateModel({
    required this.latitude,
    required this.longitude,
  });

  factory GeorouteCoordinateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeorouteCoordinateModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

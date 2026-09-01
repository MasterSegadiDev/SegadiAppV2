class GeoroutePointModel {
  final int id;
  final String name;
  final List<GeorouteCoordinateModel> coordinates;

  GeoroutePointModel({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  factory GeoroutePointModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final coordinatesJson = json['coordinates'] as List<dynamic>? ?? [];

    return GeoroutePointModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      coordinates: coordinatesJson
          .map(
            (item) => GeorouteCoordinateModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class GeorouteCoordinateModel {
  final double latitude;
  final double longitude;

  GeorouteCoordinateModel({
    required this.latitude,
    required this.longitude,
  });

  factory GeorouteCoordinateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeorouteCoordinateModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

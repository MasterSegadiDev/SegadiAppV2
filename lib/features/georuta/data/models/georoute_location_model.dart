class GeorouteLocationModel {
  final int id;
  final double? latitude;
  final double? longitude;
  final String name;

  GeorouteLocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  factory GeorouteLocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeorouteLocationModel(
      id: json['id'] ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      name: json['name']?.toString() ?? '',
    );
  }
}

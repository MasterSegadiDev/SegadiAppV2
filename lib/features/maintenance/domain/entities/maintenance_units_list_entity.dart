class MaintenanceUnitsListEntity {
  final String id;
  final String assignEmployee;
  final String assignEmployeeId;
  final String brand;
  final String vehicleClass;
  final String model;
  final String plates;
  final String status;
  final String type;
  final String vehicleNumber;
  final String year;

  const MaintenanceUnitsListEntity({
    required this.id,
    required this.assignEmployee,
    required this.assignEmployeeId,
    required this.brand,
    required this.vehicleClass,
    required this.model,
    required this.plates,
    required this.status,
    required this.type,
    required this.vehicleNumber,
    required this.year,
  });

  // Número económico que verá el operador.
  String get economicNumber => vehicleNumber;

  // Indica si la unidad está activa.
  bool get isActive => status.trim().toLowerCase() == 'activa';

  // Texto auxiliar para mostrar en la tarjeta.
  String get displayName {
    final details = [
      brand,
      model,
      year,
    ].where((value) => value.trim().isNotEmpty).join(' ');

    return details.isEmpty ? 'Unidad $vehicleNumber' : details;
  }
}

import 'package:equatable/equatable.dart';

class MaintenanceUnitAssigned extends Equatable {
  final String id;
  final int kilometers;
  final String assignEmployee;
  final String assignEmployeeId;
  final String brand;
  final String vehicleClass;
  final String fuel;
  final String gps;
  final String model;
  final String plates;
  final String status;
  final String type;
  final String vehicleNumber;
  final String year;

  const MaintenanceUnitAssigned({
    required this.id,
    required this.kilometers,
    required this.assignEmployee,
    required this.assignEmployeeId,
    required this.brand,
    required this.vehicleClass,
    required this.fuel,
    required this.gps,
    required this.model,
    required this.plates,
    required this.status,
    required this.type,
    required this.vehicleNumber,
    required this.year,
  });

  @override
  List<Object?> get props => [
        id,
        kilometers,
        assignEmployee,
        assignEmployeeId,
        brand,
        vehicleClass,
        fuel,
        gps,
        model,
        plates,
        status,
        type,
        vehicleNumber,
        year,
      ];
}

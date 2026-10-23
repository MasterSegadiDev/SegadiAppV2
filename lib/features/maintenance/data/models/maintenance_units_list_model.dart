import 'package:segadi/features/maintenance/domain/entities/maintenance_units_list_entity.dart';

class MaintenanceUnitModel extends MaintenanceUnitsListEntity {
  const MaintenanceUnitModel({
    required super.id,
    required super.assignEmployee,
    required super.assignEmployeeId,
    required super.brand,
    required super.vehicleClass,
    required super.model,
    required super.plates,
    required super.status,
    required super.type,
    required super.vehicleNumber,
    required super.year,
  });

  factory MaintenanceUnitModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MaintenanceUnitModel(
      id: json['_id']?.toString() ?? '',
      assignEmployee: json['strAssignEmployee']?.toString() ?? '',
      assignEmployeeId: json['strAssignEmployeeId']?.toString() ?? '',
      brand: json['strBrand']?.toString() ?? '',
      vehicleClass: json['strClass']?.toString() ?? '',
      model: json['strModel']?.toString() ?? '',
      plates: json['strPlates']?.toString() ?? '',
      status: json['strStatus']?.toString() ?? '',
      type: json['strType']?.toString() ?? '',
      vehicleNumber: json['strVehicleNumber']?.toString() ?? '',
      year: json['strYear']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'strAssignEmployee': assignEmployee,
      'strAssignEmployeeId': assignEmployeeId,
      'strBrand': brand,
      'strClass': vehicleClass,
      'strModel': model,
      'strPlates': plates,
      'strStatus': status,
      'strType': type,
      'strVehicleNumber': vehicleNumber,
      'strYear': year,
    };
  }
}

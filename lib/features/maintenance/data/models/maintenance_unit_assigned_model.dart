import 'package:segadi/features/maintenance/domain/entities/maintenance_unit_assigned.dart';

class MaintenanceUnitDetailModel extends MaintenanceUnitAssigned {
  const MaintenanceUnitDetailModel({
    required super.id,
    required super.kilometers,
    required super.assignEmployee,
    required super.assignEmployeeId,
    required super.brand,
    required super.vehicleClass,
    required super.fuel,
    required super.gps,
    required super.model,
    required super.plates,
    required super.status,
    required super.type,
    required super.vehicleNumber,
    required super.year,
  });

  factory MaintenanceUnitDetailModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceUnitDetailModel(
      id: json['_id'] as String? ?? '',
      kilometers: (json['intKilometers'] as num?)?.toInt() ?? 0,
      assignEmployee: json['strAssignEmployee'] as String? ?? '',
      assignEmployeeId: json['strAssignEmployeeId'] as String? ?? '',
      brand: json['strBrand'] as String? ?? '',
      vehicleClass: json['strClass'] as String? ?? '',
      fuel: json['strFuel'] as String? ?? '',
      gps: json['strGPS'] as String? ?? '',
      model: json['strModel'] as String? ?? '',
      plates: json['strPlates'] as String? ?? '',
      status: json['strStatus'] as String? ?? '',
      type: json['strType'] as String? ?? '',
      vehicleNumber: json['strVehicleNumber'] as String? ?? '',
      year: json['strYear'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'intKilometers': kilometers,
      'strAssignEmployee': assignEmployee,
      'strAssignEmployeeId': assignEmployeeId,
      'strBrand': brand,
      'strClass': vehicleClass,
      'strFuel': fuel,
      'strGPS': gps,
      'strModel': model,
      'strPlates': plates,
      'strStatus': status,
      'strType': type,
      'strVehicleNumber': vehicleNumber,
      'strYear': year,
    };
  }

  MaintenanceUnitDetailModel copyWith({
    String? id,
    int? kilometers,
    String? assignEmployee,
    String? assignEmployeeId,
    String? brand,
    String? vehicleClass,
    String? fuel,
    String? gps,
    String? model,
    String? plates,
    String? status,
    String? type,
    String? vehicleNumber,
    String? year,
  }) {
    return MaintenanceUnitDetailModel(
      id: id ?? this.id,
      kilometers: kilometers ?? this.kilometers,
      assignEmployee: assignEmployee ?? this.assignEmployee,
      assignEmployeeId: assignEmployeeId ?? this.assignEmployeeId,
      brand: brand ?? this.brand,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      fuel: fuel ?? this.fuel,
      gps: gps ?? this.gps,
      model: model ?? this.model,
      plates: plates ?? this.plates,
      status: status ?? this.status,
      type: type ?? this.type,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      year: year ?? this.year,
    );
  }
}

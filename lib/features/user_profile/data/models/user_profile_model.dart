import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.nombre,
    required super.foto,
    required super.numeroEmpleado,
    required super.sitioId,
    required super.tipoEmpleado,
    required super.tipoRol,
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfileModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      foto: json['foto'] ?? '',
      numeroEmpleado: json['numero_empleado'] ?? 0,
      sitioId: json['sitio_id'] ?? '',
      tipoEmpleado: json['tipo_empleado'] ?? '',
      tipoRol: json['tipo_rol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'foto': foto,
      'numero_empleado': numeroEmpleado,
      'sitio_id': sitioId,
      'tipo_empleado': tipoEmpleado,
      'tipo_rol': tipoRol,
    };
  }
}

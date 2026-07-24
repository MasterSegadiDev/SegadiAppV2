class UserProfileEntity {
  final String id;
  final String nombre;
  final String foto;
  final int numeroEmpleado;
  final String sitioId;
  final String tipoEmpleado;
  final String tipoRol;

  const UserProfileEntity({
    required this.id,
    required this.nombre,
    required this.foto,
    required this.numeroEmpleado,
    required this.sitioId,
    required this.tipoEmpleado,
    required this.tipoRol,
  });
}

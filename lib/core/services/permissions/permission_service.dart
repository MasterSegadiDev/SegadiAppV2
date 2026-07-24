import 'permission_type.dart';

abstract class PermissionService {
  /// Solicita un permiso.
  Future<bool> request(
    PermissionType permission,
  );

  /// Verifica si un permiso ya fue concedido.
  Future<bool> isGranted(
    PermissionType permission,
  );

  /// Abre la configuración de la aplicación.
  Future<void> openSettings();
}

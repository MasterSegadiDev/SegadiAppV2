import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Cámara
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();

    return status.isGranted;
  }

  /// Ubicación
  Future<bool> requestLocation() async {
    final status = await Permission.location.request();

    return status.isGranted;
  }

  /// Notificaciones
  Future<bool> requestNotification() async {
    final status = await Permission.notification.request();

    return status.isGranted;
  }

  /// Almacenamiento (Android)
  Future<bool> requestStorage() async {
    final status = await Permission.storage.request();

    return status.isGranted;
  }

  /// Abrir configuración
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Verificar permiso de cámara
  Future<bool> hasCameraPermission() async {
    return Permission.camera.isGranted;
  }

  /// Verificar ubicación
  Future<bool> hasLocationPermission() async {
    return Permission.location.isGranted;
  }

  /// Verificar notificaciones
  Future<bool> hasNotificationPermission() async {
    return Permission.notification.isGranted;
  }

  /// Verificar almacenamiento
  Future<bool> hasStoragePermission() async {
    return Permission.storage.isGranted;
  }
}

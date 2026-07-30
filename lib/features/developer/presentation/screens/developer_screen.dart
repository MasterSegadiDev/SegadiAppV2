import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/core/connectivity/connectivity_service.dart';
import 'package:segadi/core/device/firebase/firebase_service.dart';
import 'package:segadi/core/device/location/location_service.dart';
import 'package:segadi/core/device/notifications/notification_service.dart';
import 'package:segadi/core/device/scanner/scanner_service.dart';
import 'package:segadi/core/security/session_manager.dart';

import '../../../../core/permissions/permission_service.dart';

class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({
    super.key,
  });

  @override
  ConsumerState<DeveloperScreen> createState() => DeveloperScreenState();
}

class DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Developer Screen disponible solo en Debug',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Developer Tools',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // const Text(
          //   'Device',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 12),
          // ElevatedButton(
          //   onPressed: () {},
          //   child: const Text(
          //     'Solicitar permiso Cámara',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () {},
          //   child: const Text(
          //     'Solicitar permiso Ubicación',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: _scanDocument,
          //   child: const Text(
          //     'Escanear Documento',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: _getLocation,
          //   child: const Text(
          //     'Obtener Ubicación',
          //   ),
          // ),
          // const Divider(height: 40),
          // const Text(
          //   'Firebase',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 12),
          // ElevatedButton(
          //   onPressed: getFirebaseToken,
          //   child: const Text(
          //     'Firebase Token',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: testNotification,
          //   child: const Text(
          //     'Enviar Notificación Local',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final token = await SessionManager.getAccessToken();

          //     debugPrint('TOKEN: $token');
          //   },
          //   child: const Text('Leer Token'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final authenticated = await SessionManager.isAuthenticated();

          //     debugPrint('AUTHENTICATED: $authenticated');
          //   },
          //   child: const Text('¿Autenticado?'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     await SessionManager.clearSession();

          //     final token = await SessionManager.getAccessToken();

          //     debugPrint(token.toString());
          //   },
          //   child: const Text('Cerrar sesión'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final connectivity = getIt<ConnectivityService>();

          //     final connected = await connectivity.hasConnection();

          //     debugPrint('Conectado: $connected');
          //   },
          //   child: const Text(
          //     'Validar Internet',
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final connectivity = getIt<ConnectivityService>();

          //     final type = await connectivity.connectionType();

          //     debugPrint(type.toString());
          //   },
          //   child: const Text('Tipo de conexión'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final connectivity = getIt<ConnectivityService>();

          //     if (!await connectivity.hasConnection()) {
          //       debugPrint('NO HAY INTERNET');

          //       return;
          //     }

          //     debugPrint('CONSULTANDO API...');
          //   },
          //   child: const Text('Simular petición'),
          // ),

          ElevatedButton(
            onPressed: () async {
              final permission = getIt<PermissionService>();

              final granted = await permission.requestLocation();

              debugPrint('Location: $granted');
            },
            child: const Text(
              'Permiso Ubicación',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final permission = getIt<PermissionService>();

              final granted = await permission.requestNotification();

              debugPrint('Notifications: $granted');
            },
            child: const Text(
              'Permiso Notificaciones',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final permission = getIt<PermissionService>();

              final granted = await permission.requestStorage();

              debugPrint('Storage: $granted');
            },
            child: const Text(
              'Permiso Storage',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDocument() async {
    final scanner = getIt<ScannerService>();

    final images = await scanner.scanDocument();

    if (!mounted) return;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se escaneó ningún documento.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${images.length} documento(s) escaneado(s)',
        ),
      ),
    );

    for (final image in images) {
      debugPrint(image);
    }
  }

  Future<void> _getLocation() async {
    print("entrando a get location");
    final location = getIt<LocationService>();

    final data = await location.getCurrentLocation();

    if (data == null) {
      debugPrint(
        'Sin permisos o ubicación no disponible',
      );

      return;
    }

    debugPrint(
      'Lat: ${data.latitude}',
    );

    debugPrint(
      'Lng: ${data.longitude}',
    );
  }

  Future<void> getFirebaseToken() async {
    final firebase = getIt<FirebaseService>();

    final token = await firebase.getToken();

    debugPrint("FCM TOKEN");

    debugPrint(token);
  }

  Future<void> testNotification() async {
    final notification = getIt<NotificationService>();

    await notification.show(
      title: 'SEGADI',
      body: 'Prueba',
      payload: '12345',
    );

    debugPrint("NOTIFICACION ENVIADA");
  }
}

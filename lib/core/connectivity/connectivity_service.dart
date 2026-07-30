import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// ¿Existe conexión?
  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();

    return !result.contains(ConnectivityResult.none);
  }

  /// Tipo de conexión actual
  Future<ConnectivityResult> connectionType() async {
    final result = await _connectivity.checkConnectivity();

    return result.first;
  }

  /// Escuchar cambios de conectividad
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

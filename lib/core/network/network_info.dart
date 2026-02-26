import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // En la 6.0.3 esto devuelve List<ConnectivityResult>
    final List<ConnectivityResult> results =
        await connectivity.checkConnectivity();

    // Si la lista contiene 'none', NO hay internet.
    // Si está vacía, tampoco.
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }

    // Si tiene wifi o mobile, devolvemos true
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}

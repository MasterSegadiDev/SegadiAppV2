import 'package:connectivity_plus/connectivity_plus.dart';

import '../contracts/network_info.dart';

class ConnectivityService implements NetworkInfo {
  final Connectivity connectivity;

  ConnectivityService(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return _hasConnection(result);
    } catch (e) {
      // If plugin fails, assume connected and let network calls determine actual state
      return true;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged
        .map(_hasConnection)
        .handleError((error) {
      // If plugin fails, don't emit anything
    });
  }

  bool _hasConnection(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
}

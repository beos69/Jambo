import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_checkConnection);
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    final result = await _connectivity.checkConnectivity();
    _checkConnection(result);
  }

  void _checkConnection(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    _controller.add(isConnected);
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}

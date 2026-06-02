import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _checkConnectivity();
    _monitorConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    notifyListeners();
  }

  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
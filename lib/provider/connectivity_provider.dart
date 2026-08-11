import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void updateConnection(bool value) {
    if (_isConnected == value) return;

    _isConnected = value;
    notifyListeners();
  }
}

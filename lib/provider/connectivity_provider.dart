import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/services/common/connectivity service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void updateConnection(bool value) {
    if (_isConnected == value) return;

    _isConnected = value;
    notifyListeners();
  }

  /// Runs a live connectivity check and updates [isConnected] with the result.
  /// The status stream only emits on change, so a stale `false` set from
  /// elsewhere (e.g. a failed API call) is only corrected by checking again.
  Future<bool> refresh() async {
    final connected = await ConnectivityService.instance.checkConnection();
    updateConnection(connected);
    return connected;
  }
}

import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  StreamSubscription<InternetStatus>? _subscription;
  Timer? _suppressTimer;
  bool _suppressed = false;

  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void startListening({required Function(bool isConnected) onStatusChanged}) {
    _subscription?.cancel();

    _subscription = InternetConnection().onStatusChange.listen(
      (InternetStatus status) {
        final connected = status == InternetStatus.connected;

        _isConnected = connected;

        // If updates are suppressed temporarily (e.g., during Retry),
        // skip notifying UI to prevent flicker/stuck overlay.
        if (_suppressed) return;

        onStatusChanged(connected);
      },
      onError: (error) {
        onStatusChanged(false);
      },
    );
  }

  /// Temporarily suppress status change notifications. We still update
  /// internal state but do not propagate to UI, to avoid flicker when
  /// transitioning from offline to online flows.
  void suppress(Duration duration) {
    _suppressed = true;
    _suppressTimer?.cancel();
    _suppressTimer = Timer(duration, () {
      _suppressed = false;
    });
  }

  Future<bool> checkConnection() async {
    final result = await InternetConnection().hasInternetAccess;

    _isConnected = result;

    return result;
  }

  void dispose() {
    _subscription?.cancel();
    _suppressTimer?.cancel();
  }
}

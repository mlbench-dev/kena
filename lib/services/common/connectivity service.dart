import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  StreamSubscription<InternetStatus>? _subscription;
  Timer? _suppressTimer;
  bool _suppressed = false;

  bool _isConnected = true;

  bool get isConnected => _isConnected;

  /// Checks our own backend first, with a couple of well-known fallbacks.
  /// The package defaults (one.one.one.one, icanhazip, ...) with a 3s timeout
  /// are often blocked or too slow on mobile data, which reported "offline"
  /// while the device was actually online. Any HTTP response (even 404/405
  /// for a HEAD on the root) proves the network is reachable.
  final InternetConnection _checker = InternetConnection.createInstance(
    useDefaultOptions: false,
    customCheckOptions: [
      InternetCheckOption(
        uri: Uri.parse(AppUrl.baseUrl),
        timeout: const Duration(seconds: 8),
        responseStatusFn: (_) => true,
      ),
      InternetCheckOption(
        uri: Uri.parse('https://www.google.com/generate_204'),
        timeout: const Duration(seconds: 8),
        responseStatusFn: (_) => true,
      ),
      InternetCheckOption(
        uri: Uri.parse('https://captive.apple.com/hotspot-detect.html'),
        timeout: const Duration(seconds: 8),
        responseStatusFn: (_) => true,
      ),
    ],
  );

  void startListening({required Function(bool isConnected) onStatusChanged}) {
    _subscription?.cancel();

    _subscription = _checker.onStatusChange.listen(
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
    final result = await _checker.hasInternetAccess;

    _isConnected = result;

    return result;
  }

  void dispose() {
    _subscription?.cancel();
    _suppressTimer?.cancel();
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class for managing local storage using FlutterSecureStorage.
///
/// Android: values are AES-encrypted with a key wrapped by the Android
/// Keystore (hardware-backed on devices with a TEE/StrongBox).
/// iOS: values live in the Keychain. `first_unlock_this_device` keeps them
/// out of iCloud/iTunes backups and device-to-device migration while still
/// allowing background reads (e.g. push handling) after the first unlock.
class LocalStorage {
  final storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _installMarkerKey = 'secure_storage_install_marker';

  /// Sets a key-value pair securely.
  Future<bool> setValue(String key, String value) async {
    await storage.write(key: key, value: value);
    return true;
  }

  /// Reads a value for the given key.
  Future<String?> readValue(String key) async {
    return storage.read(key: key);
  }

  /// Deletes a value for the given key.
  Future<bool> clearValue(String key) async {
    await storage.delete(key: key);
    return true;
  }

  /// Deletes every securely stored value (tokens, user, caches).
  Future<void> clearAll() async {
    await storage.deleteAll();
  }

  /// iOS keeps Keychain items after the app is uninstalled, so a reinstall
  /// would silently restore the previous user's session. SharedPreferences
  /// *is* removed on uninstall, so a missing marker means a fresh install.
  ///
  /// Existing installs that predate the marker already have other
  /// SharedPreferences keys (tour / pro-tip flags), so they are left alone.
  Future<void> clearIfFreshInstall() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_installMarkerKey) ?? false) return;
    if (prefs.getKeys().isEmpty) await clearAll();
    await prefs.setBool(_installMarkerKey, true);
  }
}

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kena_emotional_journey/provider/providers.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Marks a true cold start (main() re-run). If this prints every time you
  // background the app and reopen it, iOS is killing the process rather
  // than just suspending it — see the didChangeAppLifecycleState logging
  // in app.dart for the paused/resumed side of the picture.
  debugPrint('🚀 COLD START — main() running at ${DateTime.now()}');
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  // Edge-to-edge is enforced by the OS on Android 15+ (API 35+) regardless of
  // what the app requests, so `SystemUiMode.manual` with explicit overlays
  // (the pre-edge-to-edge API) leaves the area behind the system nav bar
  // uncomposited by Flutter, showing raw black instead of the app's
  // background. `edgeToEdge` opts in explicitly so Flutter paints its own
  // background all the way to the screen edges, behind the transparent bars.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Each step below talks to a device-dependent service (Play Services, ad
  // SDK, secure storage) with no guaranteed bound on its own. Previously the
  // native splash screen sat on top of these while they ran, so a hang or
  // throw here was invisible. With native splash removed, the same failure
  // means nothing is ever drawn, so every step is now timeout- and
  // error-guarded to make sure runApp() always eventually fires.

  /// Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));

    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, st) {
    log('Firebase init failed/timed out: $e', stackTrace: st);
  }

  // Detect current flavor (pass --dart-define=FLAVOR=development when building)
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

  // Load per-flavor .env file if available, otherwise fall back to .env
  final envFile = flavor == 'production' ? '.env' : '.env.$flavor';
  try {
    await dotenv.load(fileName: envFile);
  } catch (_) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e, st) {
      log('dotenv load failed: $e', stackTrace: st);
    }
  }

  // Single client ID per platform (not per flavor)
  final iosClientId = Platform.isIOS
      ? dotenv.env['IOS_GOOGLE_CLIENT_ID']
      : null;

  try {
    await GoogleSignIn.instance
        .initialize(
          // Android reads OAuth config from google-services.json; iOS uses the clientId
          clientId: iosClientId,
          serverClientId: dotenv.env['WEB_GOOGLE_CLIENT_ID'],
        )
        .timeout(const Duration(seconds: 10));
  } catch (e, st) {
    log('GoogleSignIn init failed/timed out: $e', stackTrace: st);
  }

  // Add cross-flavor configuration here
  try {
    await SessionController().init().timeout(const Duration(seconds: 10));
  } catch (e, st) {
    log('SessionController init failed/timed out: $e', stackTrace: st);
  }

  try {
    await AdMobService.initialize().timeout(const Duration(seconds: 10));
  } catch (e, st) {
    log('AdMobService init failed/timed out: $e', stackTrace: st);
  }

  runApp(MultiProvider(providers: providers, child: await builder()));
}

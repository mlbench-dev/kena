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
  // Always show top + bottom overlays (status bar + nav bar)
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Initialize Firebase with platform-specific options
  await Firebase.initializeApp();

  // Initialize Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // CRITICAL: Initialize Google Sign-In
  // await GoogleSignIn.instance.initialize(
  //   // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Required for Web
  // );

  // Detect current flavor (pass --dart-define=FLAVOR=development when building)
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

  // Load per-flavor .env file if available, otherwise fall back to .env
  final envFile = flavor == 'production' ? '.env' : '.env.$flavor';
  try {
    await dotenv.load(fileName: envFile);
  } catch (_) {
    await dotenv.load(fileName: ".env");
  }

  // Single client ID per platform (not per flavor)
  final iosClientId = Platform.isIOS
      ? dotenv.env['IOS_GOOGLE_CLIENT_ID']
      : null;

  await GoogleSignIn.instance.initialize(
    // Android reads OAuth config from google-services.json; iOS uses the clientId
    clientId: iosClientId,
    serverClientId: dotenv.env['WEB_GOOGLE_CLIENT_ID'],
  );
  // Add cross-flavor configuration here
  await SessionController().init();

  // TEST ADS ONLY — see ad_mob_service.dart header before ever touching
  // the ad unit IDs there.
  await AdMobService.initialize();

  runApp(MultiProvider(providers: providers, child: await builder()));
}

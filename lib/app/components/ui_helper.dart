import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UIHelper {
  /// Dark (light-background) status bar icons, without the black
  /// `systemNavigationBarColor` baked into Flutter's own
  /// [SystemUiOverlayStyle.dark]. An [AppBar]'s `systemOverlayStyle` applies
  /// via [AnnotatedRegion], which overrides whatever [setStatusBar] set for
  /// the bottom nav bar — using the stock preset here silently forces the
  /// system nav bar to solid black on every screen with an AppBar. Leaving
  /// the nav bar fields null keeps whatever [setStatusBar] already applied.
  static const SystemUiOverlayStyle statusBarDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static void setStatusBar({required Color background}) {
    final isDark = background.computeLuminance() < 0.5;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UIHelper {
  static void setStatusBar({required Color background}) {
    final isDark = background.computeLuminance() < 0.5;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

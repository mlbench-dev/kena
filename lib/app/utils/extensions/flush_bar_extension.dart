import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension FlushBarErrorMessage on BuildContext {
  Flushbar<dynamic> flushBarErrorMessage({
    required String message,
    FlushbarPosition position = FlushbarPosition.TOP,
    EdgeInsets? margin,
  }) {
    final flushbar = Flushbar<dynamic>(
      forwardAnimationCurve: Curves.decelerate,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      message: message,
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(15.r),
      flushbarPosition: position,
      backgroundColor: Color(0xFFF4D4D2),
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      messageColor: Colors.red,
      icon: const Icon(Icons.error, size: 28, color: Colors.red),
    );
    flushbar.show(this);
    return flushbar;
  }
}

extension FlushBarSuccessMessage on BuildContext {
  void flushBarSuccessMessage({required String message}) {
    showFlushbar<dynamic>(
      context: this,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        duration: const Duration(seconds: 2),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.green,
        reverseAnimationCurve: Curves.easeInOut,
        positionOffset: 20,
        icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
      )..show(this),
    );
  }
}

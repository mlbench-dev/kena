import 'package:kena_emotional_journey/app/data/exception/app_exceptions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String? handle(
    BuildContext? context,
    Object error, {
    String? defaultMessage,
    String? serviceName,
  }) {
    final label = serviceName != null ? '[$serviceName]' : '[ErrorHandler]';
    String message =
        defaultMessage ?? 'Something went wrong. Please try again.';

    if (error is AppException) {
      debugPrint('$label ❌ ${error.debugMessage}');
      message = error.userMessage;
    } else {
      debugPrint('$label ❌ Unexpected error: $error');

      // Print 10 lines of current stack trace
      final trace = StackTrace.current
          .toString()
          .split('\n')
          .take(10)
          .join('\n');
      debugPrint('$label 🧵 Stack trace:\n$trace');
    }

    if (context != null && context.mounted) {
      context.flushBarErrorMessage(message: message);
    }
    return message;
  }
}

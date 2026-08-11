import 'package:kena_emotional_journey/app/styles/color_scheme.dart'; // adjust import path if needed
import 'package:kena_emotional_journey/app/styles/typography.dart';
import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  TypographyExtension get typography =>
      Theme.of(this).extension<TypographyExtension>()!;

  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}

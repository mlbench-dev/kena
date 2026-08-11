import 'package:flutter/material.dart';

/// Represents a single pro tip that should be shown to the user
/// after a certain number of days since their first login.
class ProTip {
  /// Unique identifier for this tip (used for persistence).
  final String id;

  /// Number of days after first login when this tip becomes eligible.
  final int dayOffset;

  /// Dialog title text.
  final String title;

  /// Dialog description text.
  final String description;

  /// Label for the action button.
  final String buttonLabel;

  /// Builder that returns the icon widget for this tip.
  final Widget Function() iconBuilder;

  const ProTip({
    required this.id,
    required this.dayOffset,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.iconBuilder,
  });
}

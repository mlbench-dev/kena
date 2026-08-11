import 'package:flutter/material.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class EmotionCategory {
  final String key;
  final String title;
  final Color color;
  final Widget Function(double w, double h) emojiBuilder;
  final List<SubEmotion> subEmotions;

  EmotionCategory({
    required this.key,
    required this.title,
    required this.color,
    required this.emojiBuilder,
    required this.subEmotions,
  });
}

class SubEmotion {
  final String key;
  final String title;
  final Widget Function(double w, double h) emojiBuilder;

  SubEmotion({
    required this.key,
    required this.title,
    required this.emojiBuilder,
  });
}

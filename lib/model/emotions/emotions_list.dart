import 'package:flutter/material.dart';

import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/emotions/emotion_category.dart';

class EmotionsList {
  // ─── Static lookup helpers ────────────────────────────────────────────

  static final List<EmotionCategory> _categories =
      EmotionsList().emotionCategories;

  /// Returns the emoji widget for a category key (e.g. "mad", "powerful").
  /// Falls back to a Text widget with the emoji string if key is not found.
  static Widget getEmojiByCategoryKey(
    String key, {
    double w = 34,
    double h = 34,
    String? fallbackEmoji,
  }) {
    final category = _categories.where((c) => c.key == key).firstOrNull;
    if (category != null) return category.emojiBuilder(w, h);
    // Fallback: show the emoji string from the API if available
    return Text(fallbackEmoji ?? '❓', style: TextStyle(fontSize: w * 0.8));
  }

  /// Returns the background color for a category key.
  static Color getColorByCategoryKey(String key) {
    final category = _categories.where((c) => c.key == key).firstOrNull;
    return category?.color ?? const Color(0xFFe0e0e0);
  }

  /// Universal lookup — searches BOTH category keys and sub-emotion keys.
  /// Use this when displaying emotions from the home API response.
  static Widget getEmojiByKey(
    String key, {
    double w = 34,
    double h = 34,
    String? fallbackEmoji,
  }) {
    // 1. Check category keys first
    final category = _categories.where((c) => c.key == key).firstOrNull;
    if (category != null) return category.emojiBuilder(w, h);

    // 2. Check sub-emotion keys
    for (final cat in _categories) {
      final sub = cat.subEmotions.where((s) => s.key == key).firstOrNull;
      if (sub != null) return sub.emojiBuilder(w, h);
    }

    return Text(fallbackEmoji ?? '❓', style: TextStyle(fontSize: w * 0.8));
  }

  /// Universal color lookup — returns the parent category color for any key.
  static Color getColorByKey(String key) {
    for (final cat in _categories) {
      if (cat.key == key) return cat.color;
      if (cat.subEmotions.any((s) => s.key == key)) return cat.color;
    }
    return const Color(0xFFe0e0e0);
  }

  /// Returns the display title for any key (category or sub-emotion).
  static String getTitleByKey(String key) {
    for (final cat in _categories) {
      if (cat.key == key) return cat.title;
      final sub = cat.subEmotions.where((s) => s.key == key).firstOrNull;
      if (sub != null) return sub.title;
    }
    return key;
  }

  // ─── Instance list ────────────────────────────────────────────────────

  final List<EmotionCategory> emotionCategories = [
    EmotionCategory(
      key: "sad", // ← added
      title: "Sad",
      color: Color(0xFFe9eaff),
      emojiBuilder: (w, h) =>
          Assets.images.cryingFace.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "lonely",
          title: "Lonely",
          emojiBuilder: (w, h) =>
              Assets.images.cryingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "depressed",
          title: "Depressed",
          emojiBuilder: (w, h) =>
              Assets.images.sadFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "guilty",
          title: "Guilty",
          emojiBuilder: (w, h) =>
              Assets.images.sadFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "inferior",
          title: "Inferior",
          emojiBuilder: (w, h) =>
              Assets.images.pleadingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "inadequate",
          title: "Inadequate",
          emojiBuilder: (w, h) =>
              Assets.images.cryingCat.image(width: w, height: h),
        ),
        SubEmotion(
          key: "miserable",
          title: "Miserable",
          emojiBuilder: (w, h) => Assets
              .images
              .anxiousFaceWithWorriedNervousConcerned
              .image(width: w, height: h),
        ),
        SubEmotion(
          key: "grief",
          title: "Grief",
          emojiBuilder: (w, h) => Assets.images.cryingFace.image(
            width: w,
            height: h,
          ), // Or custom asset
        ),
        SubEmotion(
          key: "disappointed",
          title: "Disappointed",
          emojiBuilder: (w, h) =>
              Assets.images.disappointedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "empty",
          title: "Empty",
          emojiBuilder: (w, h) =>
              Assets.images.faceWithoutMouth.image(width: w, height: h),
        ),
        SubEmotion(
          key: "shame",
          title: "Shame",
          emojiBuilder: (w, h) => Assets.images.kia.image(width: w, height: h),
        ),
        SubEmotion(
          key: "embarrassed",
          title: "Embarrassed",
          emojiBuilder: (w, h) =>
              Assets.images.faceWithPeekingEye.image(width: w, height: h),
        ),
        SubEmotion(
          key: "remorse",
          title: "Remorse",
          emojiBuilder: (w, h) =>
              Assets.images.pleadingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "regret",
          title: "Regret",
          emojiBuilder: (w, h) =>
              Assets.images.sadFace.image(width: w, height: h),
        ),
      ],
    ),
    EmotionCategory(
      key: "joyful", // ← added
      title: "Joyful",
      color: Color(0xFFffebb9),
      emojiBuilder: (w, h) =>
          Assets.images.heartsFace.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "excited",
          title: "Excited",
          emojiBuilder: (w, h) =>
              Assets.images.starStruck.image(width: w, height: h),
        ),
        SubEmotion(
          key: "sexy",
          title: "Sexy",
          emojiBuilder: (w, h) =>
              Assets.images.smileOverhand.image(width: w, height: h),
        ),
        SubEmotion(
          key: "energetic",
          title: "Energetic",
          emojiBuilder: (w, h) =>
              Assets.images.aHighVoltage.image(width: w, height: h),
        ),
        SubEmotion(
          key: "playful",
          title: "Playful",
          emojiBuilder: (w, h) =>
              Assets.images.performingArts.image(width: w, height: h),
        ),
        SubEmotion(
          key: "creative",
          title: "Creative",
          emojiBuilder: (w, h) =>
              Assets.images.artistPalette.image(width: w, height: h),
        ),
        SubEmotion(
          key: "aware",
          title: "Aware",
          emojiBuilder: (w, h) => Assets.images.eye.image(width: w, height: h),
        ),
        SubEmotion(
          key: "daring",
          title: "Daring",
          emojiBuilder: (w, h) =>
              Assets.images.lionFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "fascinating",
          title: "Fascinating",
          emojiBuilder: (w, h) =>
              Assets.images.sparkles.image(width: w, height: h),
        ),
        SubEmotion(
          key: "stimulating",
          title: "Stimulating",
          emojiBuilder: (w, h) =>
              Assets.images.glowingStar.image(width: w, height: h),
        ),
        SubEmotion(
          key: "amused",
          title: "Amused",
          emojiBuilder: (w, h) =>
              Assets.images.meltingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "delighted",
          title: "Delighted",
          emojiBuilder: (w, h) =>
              Assets.images.smile.image(width: w, height: h),
        ),
        SubEmotion(
          key: "extravagant",
          title: "Extravagant",
          emojiBuilder: (w, h) =>
              Assets.images.shakingFace.image(width: w, height: h),
        ),
      ],
    ),
    EmotionCategory(
      key: "scared", // ← added
      title: "Scared",
      color: Color(0xFFffe8f5),
      emojiBuilder: (w, h) =>
          Assets.images.fearfulFace.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "anxious",
          title: "Anxious",
          emojiBuilder: (w, h) => Assets
              .images
              .anxiousFaceWithWorriedNervousConcerned
              .image(width: w, height: h),
        ),
        SubEmotion(
          key: "insecure",
          title: "Insecure",
          emojiBuilder: (w, h) =>
              Assets.images.worriedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "submissive",
          title: "Submissive",
          emojiBuilder: (w, h) =>
              Assets.images.manBowing.image(width: w, height: h),
        ),
        SubEmotion(
          key: "helpless",
          title: "Helpless",
          emojiBuilder: (w, h) =>
              Assets.images.anguishedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "confused",
          title: "Confused",
          emojiBuilder: (w, h) =>
              Assets.images.dizzyFaceCrossOnEye.image(width: w, height: h),
        ),
        SubEmotion(
          key: "rejected",
          title: "Rejected",
          emojiBuilder: (w, h) =>
              Assets.images.heartbreak.image(width: w, height: h),
        ),
        SubEmotion(
          key: "skeptical",
          title: "Skeptical",
          emojiBuilder: (w, h) =>
              Assets.images.faceWithEyebrow.image(width: w, height: h),
        ),
        SubEmotion(
          key: "bewildered",
          title: "Bewildered",
          emojiBuilder: (w, h) =>
              Assets.images.amazing.image(width: w, height: h),
        ),
        SubEmotion(
          key: "discouraged",
          title: "Discouraged",
          emojiBuilder: (w, h) =>
              Assets.images.disappointedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "insignificant",
          title: "Insignificant",
          emojiBuilder: (w, h) =>
              Assets.images.dottedLineFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "weak",
          title: "Weak",
          emojiBuilder: (w, h) =>
              Assets.images.crying.image(width: w, height: h),
        ),
        SubEmotion(
          key: "foolish",
          title: "Foolish",
          emojiBuilder: (w, h) =>
              Assets.images.joker.image(width: w, height: h),
        ),
        SubEmotion(
          key: "powerless",
          title: "Powerless",
          emojiBuilder: (w, h) =>
              Assets.images.anguishedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "pressured",
          title: "Pressured",
          emojiBuilder: (w, h) =>
              Assets.images.worriedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "stressed",
          title: "Stressed",
          emojiBuilder: (w, h) => Assets
              .images
              .anxiousFaceWithWorriedNervousConcerned
              .image(width: w, height: h),
        ),
      ],
    ),
    EmotionCategory(
      key: "peaceful", // ← added
      title: "Peaceful",
      color: Color(0xFFd3eef2),
      emojiBuilder: (w, h) =>
          Assets.images.smilingFace.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "content",
          title: "Content",
          emojiBuilder: (w, h) =>
              Assets.images.relievedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "thoughtful",
          title: "Thoughtful",
          emojiBuilder: (w, h) =>
              Assets.images.thinkingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "intimate",
          title: "Intimate",
          emojiBuilder: (w, h) =>
              Assets.images.twoHearts.image(width: w, height: h),
        ),
        SubEmotion(
          key: "loving",
          title: "Loving",
          emojiBuilder: (w, h) =>
              Assets.images.heartsFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "nurturing",
          title: "Nurturing",
          emojiBuilder: (w, h) =>
              Assets.images.cherry.image(width: w, height: h),
        ),
        SubEmotion(
          key: "trusting",
          title: "Trusting",
          emojiBuilder: (w, h) =>
              Assets.images.aHandshake.image(width: w, height: h),
        ),
        SubEmotion(
          key: "relaxed",
          title: "Relaxed",
          emojiBuilder: (w, h) =>
              Assets.images.sleepingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "responsive",
          title: "Responsive",
          emojiBuilder: (w, h) =>
              Assets.images.aDizzy.image(width: w, height: h),
        ),
        SubEmotion(
          key: "serene",
          title: "Serene",
          emojiBuilder: (w, h) => Assets.images.yoga.image(width: w, height: h),
        ),
        SubEmotion(
          key: "sentimental",
          title: "Sentimental",
          emojiBuilder: (w, h) =>
              Assets.images.thoughtBalloon.image(width: w, height: h),
        ),
        SubEmotion(
          key: "thankful",
          title: "Thankful",
          emojiBuilder: (w, h) =>
              Assets.images.slightlySmilingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "pensive",
          title: "Pensive",
          emojiBuilder: (w, h) =>
              Assets.images.flower.image(width: w, height: h),
        ),
      ],
    ),
    EmotionCategory(
      key: "mad", // ← added
      title: "Mad",
      color: Color(0xFFfcd0c9),
      emojiBuilder: (w, h) => Assets.images.zanyFace.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "frustrated",
          title: "Frustrated",
          emojiBuilder: (w, h) =>
              Assets.images.faceWithSteamFromNose.image(width: w, height: h),
        ),
        SubEmotion(
          key: "furious",
          title: "Furious",
          emojiBuilder: (w, h) =>
              Assets.images.aFaceWithSymbolsOnMouth.image(width: w, height: h),
        ),
        SubEmotion(
          key: "irritated",
          title: "Irritated",
          emojiBuilder: (w, h) =>
              Assets.images.angryFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "jealous",
          title: "Jealous",
          emojiBuilder: (w, h) =>
              Assets.images.attitudeFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "selfish",
          title: "Selfish",
          emojiBuilder: (w, h) =>
              Assets.images.devilFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "hateful",
          title: "Hateful",
          emojiBuilder: (w, h) => Assets.images.fire.image(width: w, height: h),
        ),
        SubEmotion(
          key: "hostile",
          title: "Hostile",
          emojiBuilder: (w, h) => Assets.images.rage.image(width: w, height: h),
        ),
        SubEmotion(
          key: "angry",
          title: "Angry",
          emojiBuilder: (w, h) =>
              Assets.images.angryRedFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "critical",
          title: "Critical",
          emojiBuilder: (w, h) =>
              Assets.images.aFaceWithMonocle.image(width: w, height: h),
        ),
        SubEmotion(
          key: "hurt",
          title: "Hurt",
          emojiBuilder: (w, h) =>
              Assets.images.heartbreak.image(width: w, height: h),
        ),
        SubEmotion(
          key: "rage",
          title: "Rage",
          emojiBuilder: (w, h) =>
              Assets.images.attitudeFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "annoyed",
          title: "Annoyed",
          emojiBuilder: (w, h) =>
              Assets.images.faceWithUnimpressed.image(width: w, height: h),
        ),
      ],
    ),
    EmotionCategory(
      key: "powerful", // ← added
      title: "Powerful",
      color: Color(0xFFdef9c8),
      emojiBuilder: (w, h) => Assets.images.flexed.image(width: w, height: h),
      subEmotions: [
        SubEmotion(
          key: "proud",
          title: "Proud",
          emojiBuilder: (w, h) =>
              Assets.images.lionFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "faithful",
          title: "Faithful",
          emojiBuilder: (w, h) =>
              Assets.images.aFoldedHands.image(width: w, height: h),
        ),
        SubEmotion(
          key: "appreciated",
          title: "Appreciated",
          emojiBuilder: (w, h) =>
              Assets.images.huggingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "hopeful",
          title: "Hopeful",
          emojiBuilder: (w, h) =>
              Assets.images.aRainbow.image(width: w, height: h),
        ),
        SubEmotion(
          key: "respected",
          title: "Respected",
          emojiBuilder: (w, h) =>
              Assets.images.salutingFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "important",
          title: "Important",
          emojiBuilder: (w, h) =>
              Assets.images.crown.image(width: w, height: h),
        ),
        SubEmotion(
          key: "worthwhile",
          title: "Worthwhile",
          emojiBuilder: (w, h) =>
              Assets.images.gemStone.image(width: w, height: h),
        ),
        SubEmotion(
          key: "intelligent",
          title: "Intelligent",
          emojiBuilder: (w, h) =>
              Assets.images.brain.image(width: w, height: h),
        ),
        SubEmotion(
          key: "confident",
          title: "Confident",
          emojiBuilder: (w, h) =>
              Assets.images.glassesOnFace.image(width: w, height: h),
        ),
        SubEmotion(
          key: "satisfied",
          title: "Satisfied",
          emojiBuilder: (w, h) => Assets.images.smilingFaceWithSmilingEyes
              .image(width: w, height: h),
        ),
        SubEmotion(
          key: "cheerful",
          title: "Cheerful",
          emojiBuilder: (w, h) =>
              Assets.images.celebration.image(width: w, height: h),
        ),
        SubEmotion(
          key: "wonderful",
          title: "Wonderful",
          emojiBuilder: (w, h) =>
              Assets.images.sparkles.image(width: w, height: h),
        ),
      ],
    ),
  ];
}

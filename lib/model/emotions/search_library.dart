class EmotionSearchItem {
  final String mainEmotion;
  final List<String> keywords;

  EmotionSearchItem({required this.mainEmotion, required this.keywords});
}

final List<EmotionSearchItem> emotionSearchLibrary = [
  EmotionSearchItem(
    mainEmotion: 'disappointed',
    keywords: [
      'let down',
      'crestfallen',
      'disillusioned',
      'heavy chest',
      'stomach pit',
      'sigh',
      'throat tight',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'empty',
    keywords: ['hollow', 'numb', 'void', 'hollowness', 'fatigue', 'heavy body'],
  ),
  EmotionSearchItem(
    mainEmotion: 'grief',
    keywords: [
      'sorrow',
      'mourning',
      'heartache',
      'heavy aching chest',
      'lump in throat',
      'sobbing breath',
      'hollow or painful stomach',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'regret',
    keywords: [
      'remorse',
      'rueful',
      'penitence',
      'heavy chest',
      'lump in throat',
      'tight stomach',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'remorse',
    keywords: [
      'guilt',
      'regret',
      'self-reproach',
      'heavy chest',
      'lump in throat',
      'stomach knot',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'shame',
    keywords: [
      'humiliated',
      'mortified',
      'embarrassed',
      'face flushing',
      'stomach pit',
      'slumped posture',
      'burning chest',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'depressed',
    keywords: [
      'downcast',
      'melancholic',
      'despondent',
      'hollowness',
      'fatigue',
      'heavy body',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'guilty',
    keywords: [
      'remorseful',
      'ashamed',
      'at fault',
      'face flushing',
      'stomach pit',
      'slumped posture',
      'knotted stomach',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'hurt',
    keywords: [
      'wounded',
      'injured',
      'devastated',
      'fragile',
      'heavy chest',
      'lump in throat',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'inadequate',
    keywords: [
      'insufficient',
      'unworthy',
      'deficient',
      'heavy chest',
      'slumped posture',
      'stomach pit',
      'fatigue',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'inferior',
    keywords: [
      'lesser',
      'subpar',
      'inadequate',
      'small',
      'heavy chest',
      'slumped posture',
      'stomach pit',
      'fatigue',
      'curl inside',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'lonely',
    keywords: [
      'isolated',
      'solitary',
      'forsaken',
      'disconnected',
      'empty chest',
      'withdrawn posture',
    ],
  ),
  EmotionSearchItem(
    mainEmotion: 'miserable',
    keywords: [
      'wretched',
      'unhappy',
      'gloomy',
      'heavy chest',
      'slumped posture',
      'stomach pit',
      'fatigue',
    ],
  ),
];

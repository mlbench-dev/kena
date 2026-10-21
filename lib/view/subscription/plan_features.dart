/// Plan feature lists shared by the "Choose your plan" and active
/// subscription screens, so both always show the same data.
class PlanFeatures {
  PlanFeatures._();

  /// Features every plan includes (the whole list for Freemium).
  static const List<String> base = [
    'Record core & aspirational emotions',
    'Record Daily pulse',
    'Comprehensive list of emotions',
    'Visualisation of emotions',
    'Journaling & Notes',
    'Limited activities (10 max)',
    'Limited analytics (Week & month only)',
    'Limited community features',
  ];

  static const String additionalTitle = 'Additional Features:';

  /// Extra features shown for the paid monthly/annual plans.
  static const List<String> additional = [
    'All the above',
    'Full community features',
    'Detailed analytics',
    'Search by body sensations',
    'Thought monitoring prompts',
  ];
}

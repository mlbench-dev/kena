// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

// // ── Step model ────────────────────────────────────────────────────────────────
// class _WalkthroughStep {
//   final String? highlightKey;
//   final String description;
//   final bool isLast;

//   const _WalkthroughStep({
//     required this.highlightKey,
//     required this.description,
//     this.isLast = false,
//   });
// }

// // ── Walkthrough Screen ────────────────────────────────────────────────────────
// // This is a SEPARATE full screen shown over a dark green background.
// // The home UI is rendered inside a phone-frame mockup in the center.
// // The description text sits in a white card BELOW the phone mockup.
// // The Next / Get Started button is pinned to the bottom.
// class HomeWalkthroughScreen extends StatefulWidget {
//   /// Called when the user taps Skip or Get Started
//   final VoidCallback onFinished;

//   const HomeWalkthroughScreen({super.key, required this.onFinished});

//   @override
//   State<HomeWalkthroughScreen> createState() => _HomeWalkthroughScreenState();
// }

// class _HomeWalkthroughScreenState extends State<HomeWalkthroughScreen>
//     with SingleTickerProviderStateMixin {
//   static const List<_WalkthroughStep> _steps = [
//     _WalkthroughStep(
//       highlightKey: 'aspire',
//       description:
//           'We recommend you start here. Record your current core and aspirational emotions and the activities / actions you will take to support your journey.',
//     ),
//     _WalkthroughStep(
//       highlightKey: 'forecast',
//       description:
//           'At start of day complete an emotional forecast and plan. Engage your circle. End of day reflect on how it went.',
//     ),
//     _WalkthroughStep(
//       highlightKey: 'activities',
//       description:
//           'Select or customise your activities including the frequency. See your progress weekly, monthly etc. Activities set here show in Aspire & Reflect as well.',
//     ),
//     _WalkthroughStep(
//       highlightKey: 'community',
//       description:
//           'Add 1-3 people to your support circle. See circles you are invited to and support them with comments or likes.',
//     ),
//     _WalkthroughStep(highlightKey: null, description: '', isLast: true),
//   ];

//   int _currentStep = 0;

//   // GlobalKeys for each card inside the mockup
//   final Map<String, GlobalKey> _cardKeys = {
//     'aspire': GlobalKey(),
//     'forecast': GlobalKey(),
//     'activities': GlobalKey(),
//     'community': GlobalKey(),
//     'analytics': GlobalKey(),
//   };

//   // Resolved Rects relative to the mockup Stack's coordinate space
//   final Map<String, Rect> _cardRects = {};

//   // Key on the mockup Stack so we can convert global→local
//   final GlobalKey _mockupStackKey = GlobalKey();

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//       value: 1.0,
//     );
//     _fadeAnim = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeInOut,
//     );

//     SchedulerBinding.instance.addPostFrameCallback((_) => _resolveRects());
//   }

//   void _resolveRects() {
//     if (!mounted) return;
//     final stackBox =
//         _mockupStackKey.currentContext?.findRenderObject() as RenderBox?;
//     if (stackBox == null || !stackBox.hasSize) return;

//     final Map<String, Rect> resolved = {};
//     _cardKeys.forEach((id, key) {
//       final ctx = key.currentContext;
//       if (ctx == null) return;
//       final box = ctx.findRenderObject() as RenderBox?;
//       if (box == null || !box.hasSize) return;
//       // Convert to local coords of the mockup Stack
//       final localOffset = stackBox.globalToLocal(
//         box.localToGlobal(Offset.zero),
//       );
//       resolved[id] = localOffset & box.size;
//     });
//     setState(() => _cardRects.addAll(resolved));
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   void _next() {
//     if (_currentStep < _steps.length - 1) {
//       // Animate out → increment → animate in
//       _animController.reverse().then((_) {
//         if (!mounted) return;
//         setState(() => _currentStep++);
//         _animController.forward();
//         // Re-resolve rects after step change (same cards, same positions)
//         SchedulerBinding.instance.addPostFrameCallback((_) => _resolveRects());
//       });
//     } else {
//       widget.onFinished();
//     }
//   }

//   void _skip() => widget.onFinished();

//   @override
//   Widget build(BuildContext context) {
//     final step = _steps[_currentStep];

//     return Scaffold(
//       backgroundColor: const Color(0xFF1a3a2a),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ── Top bar: Kena + Skip ────────────────────────────────────────
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   Text(
//                     'Kena',
//                     style: TextStyle(
//                       fontFamily: 'Georgia',
//                       fontSize: 28.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                   Expanded(
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: GestureDetector(
//                         onTap: _skip,
//                         child: Text(
//                           'Skip',
//                           style: TextStyle(
//                             fontSize: 15.sp,
//                             color: Colors.white,
//                             decoration: TextDecoration.underline,
//                             decorationColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Phone mockup ────────────────────────────────────────────────
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.w),
//                 child: _PhoneMockup(
//                   mockupStackKey: _mockupStackKey,
//                   cardKeys: _cardKeys,
//                   highlightKey: step.isLast ? null : step.highlightKey,
//                   cardRects: _cardRects,
//                   fadeAnimation: _fadeAnim,
//                 ),
//               ),
//             ),

//             SizedBox(height: 16.h),

//             // ── Description card ────────────────────────────────────────────
//             if (!step.isLast)
//               FadeTransition(
//                 opacity: _fadeAnim,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(18.r),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                     child: Text(
//                       step.description,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: const Color(0xFF1a3a2a),
//                         height: 1.55,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             SizedBox(height: 20.h),

//             // ── Next / Get Started button ───────────────────────────────────
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 54.h,
//                 child: ElevatedButton(
//                   onPressed: _next,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2d5a3d),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                   ),
//                   child: Text(
//                     step.isLast ? 'Get Started' : 'Next',
//                     style: TextStyle(
//                       fontSize: 17.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Phone mockup widget ───────────────────────────────────────────────────────
// class _PhoneMockup extends StatelessWidget {
//   final GlobalKey mockupStackKey;
//   final Map<String, GlobalKey> cardKeys;
//   final String? highlightKey;
//   final Map<String, Rect> cardRects;
//   final Animation<double> fadeAnimation;

//   const _PhoneMockup({
//     required this.mockupStackKey,
//     required this.cardKeys,
//     required this.highlightKey,
//     required this.cardRects,
//     required this.fadeAnimation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Center(
//           child: AspectRatio(
//             aspectRatio: 0.46,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(44.r),
//                 border: Border.all(color: Colors.black, width: 6),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.5),
//                     blurRadius: 30,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(38.r),
//                 child: Stack(
//                   key: mockupStackKey,
//                   children: [
//                     // ── Home UI inside mockup ──────────────────────────────
//                     _buildHomeUI(context),

//                     // ── Dim + cutout overlay ───────────────────────────────
//                     if (highlightKey != null &&
//                         cardRects.containsKey(highlightKey))
//                       FadeTransition(
//                         opacity: fadeAnimation,
//                         child: CustomPaint(
//                           size: Size.infinite,
//                           painter: _CutoutPainter(
//                             cutout: _paddedCutout(cardRects[highlightKey]!),
//                             radius: 22,
//                           ),
//                         ),
//                       )
//                     else if (highlightKey != null &&
//                         !cardRects.containsKey(highlightKey))
//                       // Rects not ready yet — show plain dim
//                       Container(color: Colors.black.withOpacity(0.55)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Rect _paddedCutout(Rect rect, {double padding = 5}) {
//     return Rect.fromLTWH(
//       rect.left - padding,
//       rect.top - padding,
//       rect.width + padding * 2,
//       rect.height + padding * 2,
//     );
//   }

//   // ── Mini home UI ───────────────────────────────────────────────────────────
//   // ── Mini home UI ───────────────────────────────────────────────────────────
//   Widget _buildHomeUI(BuildContext context) {
//     return Container(
//       color: const Color(0xFFF5F5F0),
//       child: Column(
//         children: [
//           // Status bar
//           Container(
//             color: const Color(0xFF1a3a2a),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//             child: Row(
//               children: [
//                 const Text(
//                   '9:41',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const Spacer(),
//                 const Icon(
//                   Icons.signal_cellular_alt,
//                   color: Colors.white,
//                   size: 12,
//                 ),
//                 const SizedBox(width: 3),
//                 const Icon(Icons.wifi, color: Colors.white, size: 12),
//                 const SizedBox(width: 3),
//                 const Icon(Icons.battery_full, color: Colors.white, size: 12),
//               ],
//             ),
//           ),

//           // App header
//           Container(
//             color: const Color(0xFF1a3a2a),
//             padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.white,
//                   child: const Icon(Icons.person, color: Colors.grey, size: 16),
//                 ),
//                 const SizedBox(width: 8),

//                 // ── FIX: Wrapped with Expanded to define layout boundaries ──
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Text(
//                         'Good Morning, alex',
//                         maxLines: 1,
//                         overflow: TextOverflow
//                             .ellipsis, // Safely cuts off username if too long
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         'Your emotional journey continues.',
//                         maxLines: 1,
//                         overflow: TextOverflow
//                             .ellipsis, // Prevents layout explosion or pixel drop
//                         style: TextStyle(color: Colors.white70, fontSize: 9),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 4), // Breathing room spacing block
//                 CircleAvatar(
//                   radius: 13,
//                   backgroundColor: Colors.white24,
//                   child: Assets.icons.notifications.svg(
//                     height: 26.h,
//                     width: 26.w,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Cards grid
//           Expanded(
//             child: SingleChildScrollView(
//               physics: const NeverScrollableScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 4),
//                     // ── ROW 1: ASPIRE & FORECAST ──
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _miniCard(
//                             id: 'aspire',
//                             title: 'Aspire',
//                             color: const Color(0xFFf8cde6),
//                             icon: const Icon(
//                               Icons.track_changes,
//                               color: Colors.black87,
//                               size: 14,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: _miniCard(
//                             id: 'forecast',
//                             title: 'Forecast',
//                             color: const Color(0xFFc9edb3),
//                             icon: const Icon(
//                               Icons.add,
//                               color: Colors.black87,
//                               size: 14,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // ── ROW 2: ACTIVITIES & COMMUNITY ──
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _miniCard(
//                             id: 'activities',
//                             title: 'Activities',
//                             color: const Color(0xFFc9edb3),
//                             icon: const Icon(
//                               Icons.bar_chart,
//                               color: Colors.black87,
//                               size: 14,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: _miniCard(
//                             id: 'community',
//                             title: 'Community',
//                             color: const Color(0xFFf8cde6),
//                             icon: Assets.icons.chat.svg(
//                               width: 16.w,
//                               height: 16.h,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _miniCard({
//     required String id,
//     required String title,
//     required Color color,
//     required Widget icon,
//     double height = 100,
//   }) {
//     return Container(
//       key: cardKeys[id],
//       height: height,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.white.withOpacity(0.9),
//             blurRadius: 3,
//             spreadRadius: -1,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 12,
//             backgroundColor: Colors.white.withOpacity(0.5),
//             child: icon,
//           ),
//           const Spacer(),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── CustomPainter: dim with rounded cutout ────────────────────────────────────
// class _CutoutPainter extends CustomPainter {
//   final Rect cutout;
//   final double radius;

//   const _CutoutPainter({required this.cutout, required this.radius});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Dim layer with hole
//     final path = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(radius)))
//       ..fillType = PathFillType.evenOdd;
//     canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.55));

//     // Pink/white highlight border around cutout
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(cutout, Radius.circular(radius)),
//       Paint()
//         ..color = const Color(0xFFf8cde6)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2.5,
//     );
//   }

//   @override
//   bool shouldRepaint(_CutoutPainter old) => old.cutout != cutout;
// }

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// =============================================================================
// CONFIGURATION — edit these values to customise the walkthrough
// =============================================================================

/// Brand colours used throughout the walkthrough.
abstract class _AppColors {
  static const darkGreen = Color(0xFF1B3A2A);
  static const midGreen = Color(0xFF2D5A3D);
  static const cardPink = Color(0xFFDDB8CE);
  static const cardGreen = Color(0xFF9CBD8C);
  static const pinkHighlight = Color(0xFFF8C8E6);
  static const descriptionText = Color(0xFF6B8F7A);
  static const screenBackground = Color(0xFFF0EDE8);
  static const chassisColor = Color(0xFF111111);
  static const avatarColor = Color(0xFFB0846A);
}

/// Phone mockup dimensions and radii.
abstract class _PhoneConfig {
  static const double width = 315; // logical pixels (scaled by .w)
  static const double height = 640; // logical pixels (scaled by .h)
  static const double borderWidth = 10.0;
  static const double outerRadius = 58.0;
  static const double innerRadius = 48.0;
}

/// All walkthrough steps. Add, remove, or reorder steps here.
/// Set [isLast] = true on the final step to show "Get Started" instead of "Next".
const List<_WalkthroughStep> _walkthroughSteps = [
  _WalkthroughStep(
    highlightKey: 'aspire',
    description:
        'We recommend you start here. Record your current core and aspirational emotions and the activities / actions you will take to support your journey.',
  ),
  _WalkthroughStep(
    highlightKey: 'forecast',
    description:
        'At start of day complete an emotional forecast and plan. Engage your circle. End of day reflect on how it went.',
  ),
  _WalkthroughStep(
    highlightKey: 'activities',
    description:
        'Select or customise your activities including the frequency. See your progress weekly, monthly etc. Activities set here show in Aspire & Reflect as well.',
  ),
  _WalkthroughStep(
    highlightKey: 'community',
    description:
        'Add 1-3 people to your support circle. See circles you are invited to and support them with comments or likes.',
  ),
  _WalkthroughStep(highlightKey: null, description: '', isLast: true),
];

// =============================================================================
// DATA MODELS
// =============================================================================

/// Represents a single walkthrough step.
/// [highlightKey] must match a key in [_HomeUI._cardDefinitions].
/// [isLast] switches the button label to "Get Started".
class _WalkthroughStep {
  const _WalkthroughStep({
    required this.highlightKey,
    required this.description,
    this.isLast = false,
  });

  final String? highlightKey;
  final String description;
  final bool isLast;
}

/// Immutable data class describing a single home-screen card.
class _CardDef {
  const _CardDef({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
  });

  /// Must match a key in [_HomeWalkthroughScreenState._cardKeys].
  final String id;
  final String title;
  final Color color;
  final IconData icon;
}

// =============================================================================
// SCREEN
// =============================================================================

/// Full-screen walkthrough that highlights each home-screen card in sequence.
/// Call [onFinished] when the user taps "Get Started" or "Skip".
class HomeWalkthroughScreen extends StatefulWidget {
  const HomeWalkthroughScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<HomeWalkthroughScreen> createState() => _HomeWalkthroughScreenState();
}

class _HomeWalkthroughScreenState extends State<HomeWalkthroughScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  int _currentStep = 0;

  /// One GlobalKey per card so we can measure each card's position on screen.
  final Map<String, GlobalKey> _cardKeys = {
    'aspire': GlobalKey(),
    'forecast': GlobalKey(),
    'activities': GlobalKey(),
    'community': GlobalKey(),
  };

  /// Resolved screen-space rectangles for each card (populated after layout).
  final Map<String, Rect> _cardRects = {};

  /// Key on the mockup Stack — used as the coordinate origin for [_cardRects].
  final GlobalKey _mockupStackKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0, // start fully visible
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    // Resolve card positions after the first frame.
    SchedulerBinding.instance.addPostFrameCallback((_) => _resolveCardRects());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  /// Walks the render tree to record each card's rect relative to the mockup
  /// Stack, so [_CutoutPainter] knows exactly where to draw the highlight.
  void _resolveCardRects() {
    if (!mounted) return;

    final stackBox =
        _mockupStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final resolved = <String, Rect>{};
    _cardKeys.forEach((id, key) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final localOffset = stackBox.globalToLocal(
        box.localToGlobal(Offset.zero),
      );
      resolved[id] = localOffset & box.size;
    });

    setState(() => _cardRects.addAll(resolved));
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _onNext() {
    if (_currentStep < _walkthroughSteps.length - 1) {
      // Fade out → advance step → fade in.
      _animController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentStep++);
        _animController.forward();
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _resolveCardRects(),
        );
      });
    } else {
      widget.onFinished();
    }
  }

  void _onSkip() => widget.onFinished();

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final step = _walkthroughSteps[_currentStep];
    const hPad = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(onSkip: _onSkip, hPad: hPad),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: _PhoneMockup(
                  mockupStackKey: _mockupStackKey,
                  cardKeys: _cardKeys,
                  cardRects: _cardRects,
                  fadeAnimation: _fadeAnim,
                  highlightKey: step.isLast ? null : step.highlightKey,
                  description: step.isLast ? null : step.description,
                ),
              ),
            ),
            _NextButton(
              label: step.isLast ? 'Get Started' : 'Next',
              hPad: hPad,
              onPressed: _onNext,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TOP BAR
// =============================================================================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip, required this.hPad});

  final VoidCallback onSkip;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14.h),
      child: Row(
        children: [
          // Left spacer keeps the logo centred.
          const Spacer(),
          Text(
            'Kena',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: _AppColors.darkGreen,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: _AppColors.darkGreen,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: _AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// NEXT / GET STARTED BUTTON
// =============================================================================

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.hPad,
    required this.onPressed,
  });

  final String label;
  final double hPad;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16.h),
        child: SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.midGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PHONE MOCKUP SHELL
// =============================================================================

/// Renders a phone chassis that bleeds off the bottom edge of its parent,
/// giving the illusion of a full-height device screen.
///
/// Layout strategy:
///   1. [ClipRect] + [OverflowBox] lets the phone exceed the parent height.
///   2. [ClipRRect] on the outer [SizedBox] removes the sharp top corners that
///      would otherwise appear where the chassis fill overlaps the clip boundary.
///   3. [_OpenBottomChassisPainter] draws top + sides only — no bottom border.
///   4. The inner [ClipRRect] clips the screen content to [innerRadius].
class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({
    required this.mockupStackKey,
    required this.cardKeys,
    required this.cardRects,
    required this.fadeAnimation,
    required this.highlightKey,
    required this.description,
  });

  final GlobalKey mockupStackKey;
  final Map<String, GlobalKey> cardKeys;
  final Map<String, Rect> cardRects;
  final Animation<double> fadeAnimation;
  final String? highlightKey;
  final String? description;

  /// Expands a card rect by [padding] on all sides for the highlight stroke.
  Rect _padRect(Rect r, {double padding = 5}) => Rect.fromLTWH(
    r.left - padding,
    r.top - padding,
    r.width + padding * 2,
    r.height + padding * 2,
  );

  @override
  Widget build(BuildContext context) {
    const border = _PhoneConfig.borderWidth;
    const outerR = _PhoneConfig.outerRadius;
    const innerR = _PhoneConfig.innerRadius;

    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: ClipRRect(
            // Clips the chassis fill to rounded corners — fixes the sharp
            // top-left / top-right corner artefact.
            borderRadius: BorderRadius.circular(outerR),
            child: SizedBox(
              width: _PhoneConfig.width.w,
              height: _PhoneConfig.height.h,
              child: Stack(
                children: [
                  // ── Phone chassis (black shell + open bottom) ──────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _OpenBottomChassisPainter(
                        outerRadius: outerR,
                        borderWidth: border,
                        borderColor: _AppColors.chassisColor,
                        fillColor: _AppColors.chassisColor,
                        shadowColor: Colors.black.withOpacity(0.45),
                      ),
                    ),
                  ),

                  // ── Screen content ─────────────────────────────────────
                  Positioned(
                    left: border,
                    right: border,
                    top: border,
                    bottom: border,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(innerR),
                      child: Stack(
                        key: mockupStackKey,
                        children: [
                          // Home UI (cards, header, description card)
                          _HomeUI(
                            cardKeys: cardKeys,
                            description: description,
                            fadeAnimation: fadeAnimation,
                          ),

                          // Cutout highlight overlay (only when a key is set
                          // and its rect has been measured).
                          if (highlightKey != null &&
                              cardRects.containsKey(highlightKey))
                            FadeTransition(
                              opacity: fadeAnimation,
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _CutoutPainter(
                                  cutout: _padRect(cardRects[highlightKey]!),
                                  radius: 24,
                                  highlightColor: _AppColors.pinkHighlight,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CHASSIS PAINTER
// =============================================================================

/// Draws the phone chassis:
///   • Fills the full rounded-rect with [fillColor].
///   • Strokes the top arc + two side lines only — bottom is open/unclosed.
///   • Adds a soft drop shadow along the top and sides.
class _OpenBottomChassisPainter extends CustomPainter {
  const _OpenBottomChassisPainter({
    required this.outerRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
  });

  final double outerRadius;
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final r = outerRadius;

    // 1. Shadow — drawn before fill so it sits behind the chassis.
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, h),
      Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35),
    );

    // 2. Fill — full rounded rect.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(r)),
      Paint()..color = fillColor,
    );

    // 3. Border stroke — top arc + sides only (no bottom line).
    final bw = borderWidth / 2; // inset by half stroke width
    final br = r - bw;
    canvas.drawPath(
      Path()
        ..moveTo(bw, h)
        ..lineTo(bw, br)
        ..arcToPoint(Offset(br, bw), radius: Radius.circular(br))
        ..lineTo(w - br, bw)
        ..arcToPoint(Offset(w - bw, br), radius: Radius.circular(br))
        ..lineTo(w - bw, h),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_OpenBottomChassisPainter old) => false;
}

// =============================================================================
// HOME UI (SCREEN CONTENT)
// =============================================================================

/// The simulated home screen rendered inside the phone mockup.
///
/// Card definitions are centralised in [_cardDefinitions] — add, remove,
/// or reorder cards there without touching the layout code.
class _HomeUI extends StatelessWidget {
  const _HomeUI({
    required this.cardKeys,
    required this.description,
    required this.fadeAnimation,
  });

  final Map<String, GlobalKey> cardKeys;
  final String? description;
  final Animation<double> fadeAnimation;

  // ---------------------------------------------------------------------------
  // Card definitions — edit here to add / remove / reorder cards
  // ---------------------------------------------------------------------------

  static const _cardDefinitions = [
    // Row 1
    [
      _CardDef(
        id: 'aspire',
        title: 'Aspire',
        color: _AppColors.cardPink,
        icon: Icons.track_changes,
      ),
      _CardDef(
        id: 'forecast',
        title: 'Forecast',
        color: _AppColors.cardGreen,
        icon: Icons.add,
      ),
    ],
    // Row 2
    [
      _CardDef(
        id: 'activities',
        title: 'Activities',
        color: _AppColors.cardGreen,
        icon: Icons.bar_chart,
      ),
      _CardDef(
        id: 'community',
        title: 'Community',
        color: _AppColors.cardPink,
        icon: Icons.chat_bubble_outline,
      ),
    ],
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _AppColors.screenBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBar(),
          _buildAppHeader(),
          _buildCardsGrid(),
          if (description != null) _buildDescriptionCard(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  Widget _buildStatusBar() {
    return Container(
      color: _AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: const [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_alt, color: Colors.white, size: 12),
          SizedBox(width: 3),
          Icon(Icons.wifi, color: Colors.white, size: 12),
          SizedBox(width: 3),
          Icon(Icons.battery_full, color: Colors.white, size: 12),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      color: _AppColors.darkGreen,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _AppColors.avatarColor,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Good Morning, alex',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your emotional journey continues.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white60, fontSize: 9.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Notification bell
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          for (int i = 0; i < _cardDefinitions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildCardRow(_cardDefinitions[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildCardRow(List<_CardDef> defs) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (int i = 0; i < defs.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _buildCard(defs[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(_CardDef def) {
    return Container(
      key: cardKeys[def.id],
      height: 100,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: def.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.50),
            ),
            child: Icon(def.icon, color: Colors.black87, size: 15),
          ),
          const Spacer(),
          Text(
            def.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            description!,
            style: TextStyle(
              fontSize: 11.sp,
              color: _AppColors.descriptionText,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CUTOUT OVERLAY PAINTER
// =============================================================================

/// Paints a semi-transparent dark overlay over the entire screen with a
/// rounded-rectangle "hole" cut out at [cutout], revealing the card beneath.
/// A coloured stroke is drawn around the hole to draw the user's eye to it.
class _CutoutPainter extends CustomPainter {
  const _CutoutPainter({
    required this.cutout,
    required this.radius,
    required this.highlightColor,
  });

  final Rect cutout;
  final double radius;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Guard against invalid rects that can appear before layout completes.
    if (size.isEmpty || cutout.isEmpty) return;
    if (cutout.left.isNaN ||
        cutout.top.isNaN ||
        cutout.width.isNaN ||
        cutout.height.isNaN)
      return;

    final cutoutRRect = RRect.fromRectAndRadius(
      cutout,
      Radius.circular(radius),
    );

    // Dark overlay with an even-odd "hole" punched at the card position.
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(cutoutRRect)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withOpacity(0.55),
    );

    // Highlight stroke around the cutout.
    canvas.drawRRect(
      cutoutRRect,
      Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(_CutoutPainter old) =>
      old.cutout != cutout ||
      old.radius != radius ||
      old.highlightColor != highlightColor;
}

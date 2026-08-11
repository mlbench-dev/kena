import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/tour_manager.dart';
import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/view/home/widgets/tour_tooltip.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Shows a step-by-step "spotlight" tour over a screen: one widget is
/// highlighted at a time, with a tooltip describing it.
///
/// Usage:
/// ```dart
/// TourController.start(
///   context: context,
///   sectionKey: TourSections.home,
///   targetKeys: [firstButtonKey, secondButtonKey],
/// );
/// ```
class TourController {
  TourController._();

  static final OnboardingTourService _tourService = OnboardingTourService();

  /// Starts the tour for [sectionKey], highlighting each widget in
  /// [targetKeys] in order (one [TourStep] per target).
  ///
  /// Does nothing if there are no steps/targets to show.
  ///
  /// Returns a [TourHandle]. The overlay it shows lives in the root
  /// [Overlay], independent of the screen that started it, so callers
  /// **must** call `handle.cancel()` from their `dispose()` — otherwise a
  /// screen popped mid-tour leaves an orphaned overlay behind that can call
  /// `onStepChanged`/`onComplete` and crash with "setState() called after
  /// dispose()".
  static TourHandle start({
    required BuildContext context,
    required String sectionKey,
    required List<GlobalKey> targetKeys,
    void Function(int index)? onStepChanged,
    VoidCallback? onComplete,
  }) {
    final handle = TourHandle();
    _start(
      handle: handle,
      context: context,
      sectionKey: sectionKey,
      targetKeys: targetKeys,
      onStepChanged: onStepChanged,
      onComplete: onComplete,
    );
    return handle;
  }

  static Future<void> _start({
    required TourHandle handle,
    required BuildContext context,
    required String sectionKey,
    required List<GlobalKey> targetKeys,
    void Function(int index)? onStepChanged,
    VoidCallback? onComplete,
  }) async {
    if (await _tourService.isTourShown(sectionKey)) return;
    //    const alreadyShown =
    //        false;
    //         // Testing override: always show tour on every visit
    //  if (alreadyShown) return;

    if (handle._cancelled) return;

    final steps = TourContent.stepsFor(sectionKey);

    // Never try to show more steps than we have target widgets for.
    final stepCount = steps.length.clamp(0, targetKeys.length);
    if (stepCount == 0) return;
    if (!context.mounted) return;

    final session = _TourSession(
      context: context,
      tourService: _tourService,
      sectionKey: sectionKey,
      steps: steps,
      targetKeys: targetKeys,
      stepCount: stepCount,
      onStepChanged: onStepChanged,
      onComplete: onComplete,
    );
    handle._session = session;
    session.start();
  }
}

/// Handle returned by [TourController.start]. Call [cancel] from the host
/// widget's `dispose()` to tear down the tour overlay if the screen is
/// removed before the tour finishes on its own.
class TourHandle {
  bool _cancelled = false;
  _TourSession? _session;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _session?._cancel();
  }
}

// ---------------------------------------------------------------------------
// Tour session: walks through the steps one at a time
// ---------------------------------------------------------------------------

/// Runs a single tour from the first step to the last, showing one overlay
/// at a time and advancing when the user taps "Next" or "Skip".
///
/// Keeping this as its own small class (instead of passing a dozen
/// parameters between static methods) makes the step-advancing logic easy
/// to follow.
class _TourSession {
  _TourSession({
    required this.context,
    required this.tourService,
    required this.sectionKey,
    required this.steps,
    required this.targetKeys,
    required this.stepCount,
    this.onStepChanged,
    this.onComplete,
  });

  final BuildContext context;
  final OnboardingTourService tourService;
  final String sectionKey;
  final List<TourStep> steps;
  final List<GlobalKey> targetKeys;
  final int stepCount;
  final void Function(int index)? onStepChanged;
  final VoidCallback? onComplete;

  OverlayEntry? _entry;
  int _currentIndex = 0;
  bool _disposed = false;

  void start() {
    onStepChanged?.call(0);
    // Wait a frame so the target widgets are laid out before we try to
    // measure their position on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && context.mounted) {
        _currentIndex = 0;
        _entry = OverlayEntry(
          builder: (_) => TourOverlay(
            step: steps[_currentIndex],
            targetKey: targetKeys[_currentIndex],
            currentIndex: _currentIndex,
            totalSteps: stepCount,
            onNext: () => _handleNext(_currentIndex),
            onSkip: _handleSkip,
          ),
        );
        Overlay.of(context).insert(_entry!);
      }
    });
  }

  void _handleNext(int index) {
    final nextIndex = index + 1;

    if (nextIndex < stepCount && context.mounted) {
      _currentIndex = nextIndex;
      onStepChanged?.call(nextIndex);
      _entry?.markNeedsBuild();
    } else {
      _finish();
    }
  }

  void _handleSkip() {
    _finish();
  }

  void _finish() {
    _entry?.remove();
    _entry = null;
    tourService.markTourShown(sectionKey);
    onComplete?.call();
  }

  /// Tears the overlay down without marking the tour as shown or invoking
  /// [onComplete] — used when the host screen is disposed mid-tour, so the
  /// user never actually saw/finished it.
  void _cancel() {
    if (_disposed) return;
    _disposed = true;
    _entry?.remove();
    _entry = null;
  }
}

// ---------------------------------------------------------------------------
// Overlay widget: spotlight + tooltip for a single step
// ---------------------------------------------------------------------------

/// Sizing/spacing constants for [TourOverlay], grouped in one place so
/// they're easy to find and tweak.
class TourOverlayLayout {
  TourOverlayLayout._();

  static const double tooltipWidth = 260.0;
  static const double tooltipHeight = 190.0;

  /// Gap between the highlighted target and the tooltip.
  static const double gap = 18.0;

  /// Minimum distance from the tooltip to the screen edges.
  static const double screenPadding = 16.0;

  /// Corner radius of the "cut out" spotlight hole.
  static const double spotlightRadius = 15.0;
}

/// A full-screen overlay that dims everything except [targetKey]'s widget,
/// and shows a tooltip with [step]'s content next to it.
class TourOverlay extends StatefulWidget {
  const TourOverlay({
    super.key,
    required this.step,
    required this.targetKey,
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
  });

  final TourStep step;
  final GlobalKey targetKey;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay>
    with TickerProviderStateMixin {
  Rect? _currentTargetRect;
  Rect? _previousTargetRect;
  late final AnimationController _transitionController;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _transitionController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 350),
        )..addListener(() {
          setState(() {});
        });

    _updateTargetRect();

    // The target's position can change after we first measure it (e.g. the
    // screen scrolls, or content above it resizes), so we keep re-measuring
    // every frame rather than measuring just once.
    _ticker = createTicker((_) => _updateTargetRect());
    _ticker.start();
  }

  @override
  void didUpdateWidget(covariant TourOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetKey != widget.targetKey) {
      _previousTargetRect = _animatedTargetRect ?? _currentTargetRect;
      _updateTargetRect();
      _transitionController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  /// Finds the current screen position/size of the widget attached to
  /// [TourOverlay.targetKey], and updates [_currentTargetRect] if it changed.
  void _updateTargetRect() {
    if (!mounted) return;

    final box =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      if (_currentTargetRect != null) {
        setState(() => _currentTargetRect = null);
      }
      return;
    }

    final newRect = box.localToGlobal(Offset.zero) & box.size;
    if (_currentTargetRect != newRect) {
      setState(() => _currentTargetRect = newRect);
    }
  }

  Rect? get _animatedTargetRect {
    if (_previousTargetRect == null || _currentTargetRect == null) {
      return _currentTargetRect;
    }
    if (!_transitionController.isAnimating) {
      return _currentTargetRect;
    }
    final t = Curves.easeInOutCubic.transform(_transitionController.value);
    return Rect.lerp(_previousTargetRect, _currentTargetRect, t);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [_buildSpotlightBackdrop(), _buildTooltip(screenSize)],
      ),
    );
  }

  /// The dimmed background with a "hole" cut out around the target.
  Widget _buildSpotlightBackdrop() {
    return Positioned.fill(
      child: GestureDetector(
        // Swallow taps so they don't reach whatever is underneath.
        onTap: () {},
        child: CustomPaint(
          painter: SpotlightPainter(targetRect: _animatedTargetRect),
        ),
      ),
    );
  }

  Widget _buildTooltip(Size screenSize) {
    final target = _animatedTargetRect;

    return Positioned(
      left: target == null
          ? (screenSize.width - TourOverlayLayout.tooltipWidth) / 2
          : _tooltipLeft(target, screenSize),
      top: target == null
          ? (screenSize.height - TourOverlayLayout.tooltipHeight) / 2
          : _tooltipTop(target, screenSize),
      child: TourTooltip(
        title: widget.step.title,
        description: widget.step.description,
        currentStep: widget.currentIndex,
        totalSteps: widget.totalSteps,
        isLastStep: widget.currentIndex == widget.totalSteps - 1,
        onNext: widget.onNext,
        onSkip: widget.onSkip,
      ),
    );
  }

  /// Horizontally centers the tooltip under/over the target, clamped so it
  /// never goes off screen.
  double _tooltipLeft(Rect target, Size screen) {
    final ideal = target.center.dx - TourOverlayLayout.tooltipWidth / 2;
    return ideal.clamp(
      TourOverlayLayout.screenPadding,
      screen.width -
          TourOverlayLayout.tooltipWidth -
          TourOverlayLayout.screenPadding,
    );
  }

  /// Places the tooltip below the target if there's room, otherwise above it.
  double _tooltipTop(Rect target, Size screen) {
    final below = target.bottom + TourOverlayLayout.gap;
    final fitsBelow =
        below + TourOverlayLayout.tooltipHeight <
        screen.height - TourOverlayLayout.screenPadding * 2;

    return fitsBelow
        ? below
        : (target.top - TourOverlayLayout.gap - TourOverlayLayout.tooltipHeight)
              .clamp(
                TourOverlayLayout.screenPadding * 2,
                screen.height - TourOverlayLayout.screenPadding * 2,
              );
  }
}

// ---------------------------------------------------------------------------
// Painter: dims the screen except for a hole around the target
// ---------------------------------------------------------------------------

/// Paints a dark overlay covering the whole screen, with a rounded-rect
/// "hole" cut out at [targetRect] so that widget stays visible.
class SpotlightPainter extends CustomPainter {
  SpotlightPainter({this.targetRect, this.borderRadius = 12});

  final Rect? targetRect;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final backdrop = Path()..addRect(Offset.zero & size);

    final target = targetRect;
    if (target == null) {
      // No target measured yet — just dim the whole screen.
      canvas.drawPath(backdrop, paint);
      return;
    }

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(target.inflate(0), Radius.circular(15.r)),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, backdrop, hole),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}

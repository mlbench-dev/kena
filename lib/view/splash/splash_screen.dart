import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  // --- Timeline ---------------------------------------------------------
  static const _blobs = Duration.zero;
  static const _logo = Duration(milliseconds: 300);
  static const _wordmark = Duration(milliseconds: 600);
  static const _tagline = Duration(milliseconds: 900);
  static const _taglineStep = Duration(milliseconds: 120);
  static const _subtitle = Duration(milliseconds: 1400);
  static const _illustration = Duration(milliseconds: 1600);
  static const _welcome = Duration(milliseconds: 2300);

  // Total time on screen before navigating on: long enough for the welcome
  // label's entrance to finish reading, short enough not to feel like a delay.
  static const _navigateAfter = Duration(milliseconds: 3000);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(SplashScreen._navigateAfter, () {
      if (!mounted) return;
      AuthService().checkAuthentication(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Respect the OS "reduce motion" setting — looping ambient motion is
    // disabled and entrances collapse to a plain fade.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return MyScaffold(
      isSafeArea: false,
      body: Stack(
        children: [
          _CoralBlob(reduceMotion: reduceMotion),
          _TealEllipse(reduceMotion: reduceMotion),
          _CenterContent(reduceMotion: reduceMotion),
          _BottomIllustration(reduceMotion: reduceMotion),
          _WelcomeLabel(reduceMotion: reduceMotion),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background blobs
// ---------------------------------------------------------------------------

class _CoralBlob extends StatelessWidget {
  const _CoralBlob({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final blob = Assets.icons.vectors.svg();

    // Inner loop: a slow drift so the corner never feels static.
    final floating = reduceMotion ? blob : blob;

    return Positioned(
      left: 0,
      top: 0,
      // Outer chain: the entrance. Anchored top-left so it grows out of
      // the corner rather than from its own centre.
      child: floating
          .animate()
          .fadeIn(delay: SplashScreen._blobs, duration: 700.ms)
          .scale(
            begin: const Offset(0.6, 0.6),
            end: const Offset(1, 1),
            alignment: Alignment.topLeft,
            duration: 700.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _TealEllipse extends StatelessWidget {
  const _TealEllipse({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final ellipse = Assets.icons.ellipse.svg();

    // Deliberately a different period from the coral blob (4s vs 5s) so the
    // two never drift in lockstep.
    final floating = reduceMotion
        ? ellipse
        : Animate(
            onPlay: (c) => c.repeat(reverse: true),
            effects: [
              MoveEffect(
                begin: Offset.zero,
                end: const Offset(0, 10),
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),
            ],
            child: ellipse,
          );

    return Positioned(
      left: 98,
      top: 50,
      child: floating
          .animate()
          .fadeIn(delay: 150.ms, duration: 700.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 700.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo, wordmark, tagline, subtitle
// ---------------------------------------------------------------------------

class _CenterContent extends StatelessWidget {
  const _CenterContent({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 150.h),
          _Logo(reduceMotion: reduceMotion),
          SizedBox(height: 12.h),
          const _Wordmark(),
          SizedBox(height: 18.h),
          const _Tagline(),
          SizedBox(height: 14.h),
          const _Subtitle(),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
      decoration: BoxDecoration(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30.w),
      ),
      child: Assets.icons.logo.logo.svg(width: 80.w, height: 85.w),
    );

    if (reduceMotion) {
      return logo.animate().fadeIn(delay: SplashScreen._logo, duration: 400.ms);
    }

    // easeOutBack gives the slight overshoot that stops this reading as a
    // stock fade. The tiny counter-rotation settles with it.
    return logo
        .animate()
        .fadeIn(delay: SplashScreen._logo, duration: 500.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .rotate(begin: -0.022, end: 0, duration: 700.ms, curve: Curves.easeOut);
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Text(
          'Kena',
          style: GoogleFonts.momoTrustDisplay(
            fontSize: 50.sp,
            color: context.colors.tertiary,
            fontWeight: FontWeight.w400,
          ),
        )
        .animate()
        .fadeIn(delay: SplashScreen._wordmark, duration: 500.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: SplashScreen._wordmark,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Split out of the original [RichText] so each coloured phrase can arrive on
/// its own beat — the coral → teal → navy handoff is the moment on this screen.
class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    final base = context.typography.body.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      fontFamily: 'inter',
      height: 1.5,
    );

    Widget piece(String text, Color color, int index) {
      return Text(text, style: base.copyWith(color: color))
          .animate()
          .fadeIn(
            delay: SplashScreen._tagline + (SplashScreen._taglineStep * index),
            duration: 400.ms,
          )
          .slideY(
            begin: 0.4,
            end: 0,
            delay: SplashScreen._tagline + (SplashScreen._taglineStep * index),
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return SizedBox(
      width: 260.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              piece('Small Steps', context.colors.primary, 0),
              piece(', ', context.colors.textPrimary, 1),
              piece('Brighter ', context.colors.secondary, 2),
              piece('Days', context.colors.tertiary, 3),
            ],
          ),
          piece('Growing Together', context.colors.tertiary, 4),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: 320.w,
          child: Text(
            'Your space for self-reflection,\nmeaningful progress and real support.',
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'inter',
              height: 1.5,
              color: context.colors.textPrimary,
            ),
          ),
        )
        .animate()
        .fadeIn(delay: SplashScreen._subtitle, duration: 500.ms)
        .slideY(
          begin: 0.25,
          end: 0,
          delay: SplashScreen._subtitle,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ---------------------------------------------------------------------------
// Bottom illustration
// ---------------------------------------------------------------------------

class _BottomIllustration extends StatelessWidget {
  const _BottomIllustration({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final image = Assets.images.group.image(
      width: double.infinity,
      fit: BoxFit.cover,
    );

    if (reduceMotion) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: image.animate().fadeIn(
          delay: SplashScreen._illustration,
          duration: 500.ms,
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // begin: 1.0 shifts it a full self-height below the fold, so the group
      // rises into frame instead of appearing there.
      child: image
          .animate()
          .slideY(
            begin: 1,
            end: 0,
            delay: SplashScreen._illustration,
            duration: 800.ms,
            curve: Curves.easeOutCubic,
          )
          .fadeIn(delay: SplashScreen._illustration, duration: 500.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome
// ---------------------------------------------------------------------------

class _WelcomeLabel extends StatelessWidget {
  const _WelcomeLabel({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      'Welcome',
      style: context.typography.body.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        fontFamily: 'inter',
        height: 1.5,
        color: context.colors.tertiary,
      ),
    );

    // Inner loop: a slow breath so it reads as the thing to tap.
    final breathing = reduceMotion
        ? label
        : Animate(
            onPlay: (c) => c.repeat(reverse: true),
            effects: [
              FadeEffect(
                begin: 1,
                end: 0.55,
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
            ],
            child: label,
          );

    return Positioned(
      left: 0,
      right: 0,
      bottom: 25.h,
      child: Center(
        child: breathing.animate().fadeIn(
          delay: SplashScreen._welcome,
          duration: 600.ms,
        ),
      ),
    );
  }
}

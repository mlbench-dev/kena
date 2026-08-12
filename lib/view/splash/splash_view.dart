import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class KenaSplashScreen extends StatefulWidget {
  const KenaSplashScreen({super.key, this.appName = 'Kena', this.tagline});

  final String appName;

  /// Optional line shown under the app name, e.g. "Find your calm".
  final String? tagline;

  @override
  State<KenaSplashScreen> createState() => _KenaSplashScreenState();
}

class _KenaSplashScreenState extends State<KenaSplashScreen>
    with TickerProviderStateMixin {
  // Brand colors pulled from the logo mark.
  static const _coral = Color(0xFFF2724F);
  static const _teal = Color(0xFF7EC9C4);
  static const _navy = Color(0xFF14315C);
  static const _cream = Color(0xFFFDFBF6);

  // Entrance animation: logo scale/fade, then name/tagline fade+slide.
  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Continuous, slow drift for the background blobs — keeps running for as
  // long as the splash is on screen, independent of the entrance animation.
  late final AnimationController _driftController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _entranceController.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    // Total time on screen: ~2.6s — long enough for the breathing motion to
    // read as intentional, short enough not to feel like a delay.
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      AuthService().checkAuthentication(context);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Drifting blobs, behind everything else.
          AnimatedBuilder(
            animation: _driftController,
            builder: (context, _) {
              final t = _driftController.value;
              return Stack(
                children: [
                  _blob(
                    color: _coral,
                    size: size.width * 0.55,
                    dx: size.width * 0.10 + 14 * math.sin(t * math.pi),
                    dy: size.height * 0.16 + 10 * math.cos(t * math.pi),
                  ),
                  _blob(
                    color: _teal,
                    size: size.width * 0.5,
                    dx: size.width * 0.42 - 12 * math.cos(t * math.pi),
                    dy: size.height * 0.58 + 12 * math.sin(t * math.pi),
                  ),
                  _blob(
                    color: _navy,
                    size: size.width * 0.28,
                    dx: size.width * 0.62 + 8 * math.sin(t * math.pi),
                    dy: size.height * 0.22 - 8 * math.cos(t * math.pi),
                  ),
                ],
              );
            },
          ),

          // Logo + text, in front.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Assets.icons.kena.svg(width: 180.w, height: 180.h),
                ),
              ),
              SizedBox(height: 8.h),
              FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      Text(
                        widget.appName,
                        style: GoogleFonts.momoTrustDisplay(
                          fontSize: 40.sp,
                          color: _navy,
                          fontWeight: FontWeight.w400,
                          // fontFamily: 'sfpro',
                        ),
                      ),
                      if (widget.tagline != null) ...[
                        SizedBox(height: 8.w),
                        Text(
                          widget.tagline!,
                          style: TextStyle(
                            fontSize: 15.sp,
                            letterSpacing: 0.4,
                            color: _navy.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A soft, low-opacity organic blob used as background texture.
  Widget _blob({
    required Color color,
    required double size,
    required double dx,
    required double dy,
  }) {
    return Positioned(
      left: dx,
      top: dy,
      child: Opacity(
        opacity: 0.16,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size * 0.55),
              topRight: Radius.circular(size * 0.45),
              bottomLeft: Radius.circular(size * 0.4),
              bottomRight: Radius.circular(size * 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

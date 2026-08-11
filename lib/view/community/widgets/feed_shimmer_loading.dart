import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class FeedsShimmer extends StatelessWidget {
  const FeedsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(2, (_) => const _FeedCardShimmer()),
      ),
    );
  }
}

class _FeedCardShimmer extends StatelessWidget {
  const _FeedCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author header ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circle
              Container(
                width: 45.r,
                height: 45.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _Box(width: 120.w, height: 14.h),
                  SizedBox(height: 6.h),
                  // Date
                  _Box(width: 90.w, height: 11.h),
                ],
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // ── Forecast card skeleton ────────────────────────────────
          _CardSkeleton(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Forecast" title
                _Box(width: 80.w, height: 16.h),
                SizedBox(height: 12.h),
                // Emotion chips row
                Row(
                  children: [
                    _ChipBox(width: 95.w),
                    SizedBox(width: 8.w),
                    _ChipBox(width: 78.w),
                  ],
                ),
                SizedBox(height: 12.h),
                // Emotion image slots (up to 3 side-by-side, like real feed)
                _ImageRowSkeleton(),
                SizedBox(height: 12.h),
                // Notes line ("quoted" text)
                _Box(width: double.infinity, height: 12.h),
                SizedBox(height: 6.h),
                _Box(width: 190.w, height: 12.h),
                SizedBox(height: 12.h),
                // Plan box
                _FilledInsetBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Box(width: 55.w, height: 13.h, color: Colors.white),
                      SizedBox(height: 8.h),
                      _Box(
                        width: double.infinity,
                        height: 11.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 5.h),
                      _Box(width: 210.w, height: 11.h, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ── Reflection card skeleton ──────────────────────────────
          _CardSkeleton(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "End of Day" title
                _Box(width: 95.w, height: 16.h),
                SizedBox(height: 12.h),
                // Emotion chips
                Row(
                  children: [
                    _ChipBox(width: 85.w),
                    SizedBox(width: 8.w),
                    _ChipBox(width: 105.w),
                  ],
                ),
                SizedBox(height: 12.h),
                // Emotion image slots
                _ImageRowSkeleton(),
                SizedBox(height: 12.h),
                // Forecast vs actual box
                _FilledInsetBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Box(width: 140.w, height: 12.h, color: Colors.white),
                      SizedBox(height: 10.h),
                      _Box(
                        width: double.infinity,
                        height: 11.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6.h),
                      _Box(width: 170.w, height: 11.h, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── Actions row ───────────────────────────────────────────
          Row(
            children: [
              SizedBox(width: 4.w),
              _Box(width: 22.w, height: 22.h, radius: 6),
              SizedBox(width: 8.w),
              _Box(width: 40.w, height: 13.h),
              SizedBox(width: 20.w),
              _Box(width: 20.w, height: 20.h, radius: 4),
              SizedBox(width: 8.w),
              _Box(width: 20.w, height: 13.h),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }
}

// ── Reusable skeleton primitives ─────────────────────────────────────────────

/// A single skeleton "shape". Kept opaque so the shimmer sweep animates it;
/// gaps between shapes stay fully transparent so the underlying page shows
/// through, which is what makes individual bars/boxes read as distinct
/// pieces instead of one solid animated slab.
class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _Box({
    required this.width,
    required this.height,
    this.radius = 6,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _ChipBox extends StatelessWidget {
  final double width;
  const _ChipBox({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 34.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.r),
      ),
    );
  }
}

/// Mirrors the real feed's "up to 3 images side-by-side, each with a label
/// underneath" layout instead of a single wide placeholder block.
class _ImageRowSkeleton extends StatelessWidget {
  const _ImageRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const count = 3;
        final gap = 8.w;
        final itemWidth = (constraints.maxWidth - gap * (count - 1)) / count;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == count - 1 ? 0 : gap),
              child: SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Box(width: itemWidth, height: 100.h, radius: 12),
                    SizedBox(height: 6.h),
                    _Box(width: itemWidth * 0.6, height: 11.h),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// The lightly-tinted inset box used for "Plan:" / "Forecast vs Actual"
/// content inside a card — a distinct filled shape, not the card background.
class _FilledInsetBox extends StatelessWidget {
  final Widget child;
  const _FilledInsetBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}

/// Outlines a card the same way the real Forecast/Reflection cards do
/// (border + rounded corners, no solid fill). Leaving the interior
/// transparent keeps the gaps between skeleton lines/chips/images real —
/// filling it solid is what made the whole card shimmer as a single slab.
class _CardSkeleton extends StatelessWidget {
  final Widget child;
  const _CardSkeleton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}

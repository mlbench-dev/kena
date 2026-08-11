import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader mirroring the [WeeklyFeeds] screen layout:
/// prediction insights card, progress card, deviation chart,
/// forecast/actual emotion sections and top activities section.
class WeeklyFeedsShimmer extends StatelessWidget {
  const WeeklyFeedsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _Box(width: 98.w, height: 27.h, radius: 8),
              ),
              SizedBox(height: 16.h),
              const _PredictionInsightsSkeleton(),
              SizedBox(height: 16.h),
              const _ProgressCardSkeleton(),
              SizedBox(height: 16.h),
              const _DeviationChartSkeleton(),
              SizedBox(height: 16.h),
              _Box(width: 220.w, height: 17.h),
              SizedBox(height: 8.h),
              _Box(width: double.infinity, height: 13.h),
              SizedBox(height: 16.h),
              const _EmotionsSectionSkeleton(),
              SizedBox(height: 16.h),
              const _EmotionsSectionSkeleton(),
              SizedBox(height: 16.h),
              const _TopActivitiesSkeleton(),
              SizedBox(height: 16.h),
              _Box(width: double.infinity, height: 60.h, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionInsightsSkeleton extends StatelessWidget {
  const _PredictionInsightsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _CardSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Box(width: 24.w, height: 24.h, radius: 6),
              SizedBox(width: 10.w),
              _Box(width: 140.w, height: 16.h),
            ],
          ),
          SizedBox(height: 14.h),
          Center(
            child: _Box(width: 90.w, height: 40.h),
          ),
          SizedBox(height: 12.h),
          Center(
            child: _Box(width: 240.w, height: 12.h),
          ),
          SizedBox(height: 6.h),
          Center(
            child: _Box(width: 180.w, height: 12.h),
          ),
          SizedBox(height: 20.h),
          _Box(width: double.infinity, height: 1.h, radius: 0),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  _Box(width: 80.w, height: 11.h),
                  SizedBox(height: 6.h),
                  _Box(width: 30.w, height: 15.h),
                ],
              ),
              Column(
                children: [
                  _Box(width: 80.w, height: 11.h),
                  SizedBox(height: 6.h),
                  _Box(width: 30.w, height: 15.h),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCardSkeleton extends StatelessWidget {
  const _ProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Box(width: 90.w, height: 16.h),
              _Box(width: 36.w, height: 16.h),
            ],
          ),
          SizedBox(height: 12.h),
          _Box(width: double.infinity, height: 8.h, radius: 8),
        ],
      ),
    );
  }
}

class _DeviationChartSkeleton extends StatelessWidget {
  const _DeviationChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return _CardSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Box(width: 160.w, height: 16.h),
          SizedBox(height: 10.h),
          _Box(width: double.infinity, height: 115.h, radius: 8),
        ],
      ),
    );
  }
}

class _EmotionsSectionSkeleton extends StatelessWidget {
  const _EmotionsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Box(width: 140.w, height: 14.h),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 12.w),
                child: Column(
                  children: [
                    _Box(width: 56.w, height: 56.h, radius: 28),
                    SizedBox(height: 6.h),
                    _Box(width: 40.w, height: 10.h),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TopActivitiesSkeleton extends StatelessWidget {
  const _TopActivitiesSkeleton();

  @override
  Widget build(BuildContext context) {
    return _CardSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Box(width: 150.w, height: 16.h),
          SizedBox(height: 14.h),
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(width: 110.w, height: 12.h),
                  SizedBox(height: 6.h),
                  _Box(width: double.infinity, height: 10.h, radius: 5),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Reusable skeleton primitives ─────────────────────────────────────────

class _Box extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Box({required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: child,
    );
  }
}

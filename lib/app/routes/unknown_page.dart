import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(title: Text(context.l10n.unknown_oops), centerTitle: true),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '404',
                style: context.typography.title.copyWith(
                  fontSize: 64.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textOnDark,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                context.l10n.unknown_page_not_found,
                style: context.typography.label.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                context.l10n.unknown_page_does_not_exist,
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  fontSize: 14.sp,
                  color: context.colors.onSurface.withValues(alpha: .6),
                ),
              ),
              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }
}

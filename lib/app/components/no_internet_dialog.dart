import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  /// Returns `true` when online. If the cached status says offline, verifies
  /// with a live check first and only shows this dialog if that also fails.
  static Future<bool> guard(BuildContext context) async {
    final connectivity = context.read<ConnectivityProvider>();
    if (connectivity.isConnected) return true;
    if (await connectivity.refresh()) return true;
    if (context.mounted) {
      MyDialogBox.show(context, child: const NoInternetDialog());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 40.sp,
            color: context.colors.error,
          ),
          SizedBox(height: 12.h),
          Text(
            "No Internet Connection",
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please enable your internet to access this.",
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 20.h),
          MyButton(
            fontWeight: FontWeight.w600,
            label: "OK",
            onPressed: () => Navigator.pop(context),
            backgroundColor: context.colors.primary,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/l10n/l10n.dart';
import 'package:kena_emotional_journey/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

/// Slim banner shown at the top of [MyScaffold] whenever the device has no
/// internet connection, driven by [ConnectivityProvider].
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select<ConnectivityProvider, bool>(
      (provider) => provider.isConnected,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isConnected
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: context.colors.error,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: context.colors.textOnDark,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.l10n.offline_banner_message,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

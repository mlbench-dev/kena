import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class DrawerMenuItem {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isAsync;
  final bool
  isDisabled; // optional: greys out and blocks taps, e.g. while another item loads

  const DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isAsync = false,
    this.isDisabled = false,
  });
}

class MyDrawer extends StatelessWidget {
  final List<DrawerMenuItem> items;

  /// Brand color for the logo/leaf accent. Swap for context.colors.primary
  /// in your real app if you want it theme-driven instead of hardcoded.
  final Color brandColor;

  const MyDrawer({
    super.key,
    required this.items,
    this.brandColor = const Color(0xFF1B3A2B), // dark green like screenshot
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header: logo + brand name + close button ---
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 12.h),
              child: Row(
                children: [
                  Assets.icons.kena.svg(width: 32.r, height: 32.r),
                  SizedBox(width: 4.w),
                  Text(
                    'Kena',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily:
                          'serif', // swap for your app's serif/logo font
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.r, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 16.h),

            // --- "Menu" label ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // --- Menu items ---
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DrawerPillButton(item: item);
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _DrawerPillButton extends StatelessWidget {
  final DrawerMenuItem item;
  const _DrawerPillButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final isBlocked = item.isLoading || item.isDisabled;
    return Material(
      color: const Color(0xFFF5F5F5), // light gray pill background
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: isBlocked
            ? null
            : () {
                if (!item.isAsync) {
                  Navigator.pop(context); // close drawer first for sync actions
                }
                item.onTap();
              },
        child: Opacity(
          opacity: item.isDisabled ? 0.4 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                if (item.isLoading)
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: Center(
                      child: SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child: LoadingWidget(color: context.colors.textPrimary),
                      ),
                    ),
                  )
                else
                  item.icon,
                SizedBox(width: 14.w),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

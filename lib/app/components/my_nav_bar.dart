import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// ============================================================
/// TRANSPARENT "BUTTON-STYLE" NAV BAR
/// Unlike a normal bottom nav bar, this does NOT track a selected
/// index or switch tabs. Each item is just a tap target that runs
/// its own callback (e.g. your existing _onAspireTap, or a
/// Navigator.pushNamed call). Background is fully transparent so
/// it sits on top of whatever's behind it (gradient, scroll content).
/// ============================================================

class NavBarButtonItem {
  final Widget icon; // pass Icon(...) or an svg widget directly
  final String label;
  final VoidCallback onTap;
  final bool isLoading; // optional: shows a spinner instead of the icon
  final bool isDisabled; // optional: greys out and blocks taps, e.g. while another section loads
  final Key? key; // optional: key for tour targeting

  const NavBarButtonItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.key,
  });
}

class MyNavBar extends StatelessWidget {
  final List<NavBarButtonItem> items;

  const MyNavBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent, // <-- fully transparent bar
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding : 12.h,
        top: 10.h,
        left: 8.w,
        right: 8.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => _NavBarButton(item: item, key: item.key))
            .toList(),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final NavBarButtonItem item;
  const _NavBarButton({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final isBlocked = item.isLoading || item.isDisabled;
    return Expanded(
      child: Semantics(
        label: item.label,
        button: true,
        enabled: !isBlocked,
        child: InkWell(
          onTap: isBlocked
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  item.onTap();
                },
          borderRadius: BorderRadius.circular(20.r),
          child: Opacity(
            opacity: item.isDisabled ? 0.4 : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item.isLoading
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: context.colors.primary,
                            size: 18.r,
                          ),
                        )
                      : item.icon,
                  SizedBox(height: 4.h),
                  Text(
                    item.label,
                    style: context.typography.body.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                      fontFamily: 'sfpro',
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/premium_lock.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class CapsuleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Color activeColor;
  final Color inactiveTextColor;
  final double height;

  /// Indexes of tabs that show a lock icon and can't be selected.
  final Set<int> lockedTabs;

  /// Called instead of switching when a locked tab is tapped.
  final VoidCallback? onLockedTabTap;

  const CapsuleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.activeColor = const Color(0xff1b4d3e), // Default dark green
    this.inactiveTextColor = Colors.grey,
    this.height = 55.0,
    this.lockedTabs = const {},
    this.onLockedTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TabBar(
          controller: controller,
          labelColor: Colors.white,
          unselectedLabelColor: inactiveTextColor,
          labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: context.colors.secondary,
            borderRadius: BorderRadius.circular(15.r),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          dividerColor: Colors.transparent,
          onTap: (index) {
            if (!lockedTabs.contains(index)) return;
            // Undo the switch the TabBar already started.
            controller.index = controller.previousIndex;
            onLockedTabTap?.call();
          },
          tabs: [
            for (var i = 0; i < tabs.length; i++)
              lockedTabs.contains(i)
                  ? Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              tabs[i],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const PremiumBadgeIcon(size: 14),
                        ],
                      ),
                    )
                  : Tab(text: tabs[i]),
          ],
        ),
      ),
    );
  }
}

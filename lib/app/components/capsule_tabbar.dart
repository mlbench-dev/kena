import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CapsuleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Color activeColor;
  final Color inactiveTextColor;
  final double height;

  const CapsuleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.activeColor = const Color(0xff1b4d3e), // Default dark green
    this.inactiveTextColor = Colors.grey,
    this.height = 55.0,
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
            color: activeColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          dividerColor: Colors.transparent,
          tabs: tabs.map((title) => Tab(text: title)).toList(),
        ),
      ),
    );
  }
}

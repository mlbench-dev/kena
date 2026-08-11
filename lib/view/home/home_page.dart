// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/view/home/home_screen.dart';
// import 'package:kena_emotional_journey/view/community/community_screen.dart';
// import 'package:kena_emotional_journey/view/profile/insights_screen.dart';
// import 'package:kena_emotional_journey/view/profile/profile.dart';

// class NavItem {
//   final String label;
//   final AssetGenImage icon;
//   const NavItem({required this.label, required this.icon});
// }

// final List<NavItem> navItems = [
//   NavItem(label: "Home", icon: Assets.images.home),
//   NavItem(label: "Community", icon: Assets.images.community),
//   NavItem(label: "Insights", icon: Assets.images.insights),
//   NavItem(label: "Profile", icon: Assets.images.profile),
// ];

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   late final PageController _pageController;

//   final List<Widget> _screens = const [
//     HomeScreen(),
//     CommunityScreen(),
//     InsightsScreen(),
//     ProfileScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     // loadData();
//   }

//   // Future<void> loadData() async {
//   //   try {
//   //     await SessionController().init();
//   //     final data = await userHomeService.getUserDetails();
//   //     if (!mounted) return;
//   //     setState(() {
//   //       userHomeModel = data;
//   //       hasData = (data?.data?.isNotEmpty ?? false);
//   //     });
//   //   } catch (e) {
//   //     debugPrint('❌ Error loading home data: $e');
//   //     if (!mounted) return;
//   //     setState(() {
//   //       hasData = false;
//   //     });
//   //   }
//   // }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onTabTapped(int index) {
//     final distance = (_selectedIndex - index).abs();
//     setState(() => _selectedIndex = index);

//     if (distance > 1) {
//       _pageController.jumpToPage(index);
//     } else {
//       _pageController.animateToPage(
//         index,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   Widget _buildIcon(AssetGenImage icon, bool isSelected) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//       transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
//       child: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 250),
//         child: ColorFiltered(
//           key: ValueKey(isSelected),
//           colorFilter: ColorFilter.mode(
//             isSelected ? context.colors.primary : Colors.grey,
//             BlendMode.srcIn,
//           ),
//           child: icon.image(height: 24.h, width: 24.w),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() => _selectedIndex = index);
//         },
//         physics: const ClampingScrollPhysics(),
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: context.colors.background,
//         currentIndex: _selectedIndex,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: context.colors.primary,
//         unselectedItemColor: Colors.grey,
//         selectedFontSize: 12.sp,
//         unselectedFontSize: 11.sp,
//         showUnselectedLabels: true,
//         onTap: _onTabTapped,
//         items: List.generate(
//           navItems.length,
//           (i) => BottomNavigationBarItem(
//             icon: _buildIcon(navItems[i].icon, i == _selectedIndex),
//             label: navItems[i].label,
//           ),
//         ),
//       ),
//     );
//   }
// }

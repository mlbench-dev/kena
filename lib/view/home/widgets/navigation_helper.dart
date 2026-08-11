// import 'package:flutter/material.dart';

// class NavigationHelper {
//   /// Push a page with animation like native pop, faster speed
//   static void pushLikePop(BuildContext context, Widget page) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 250), // faster
//         pageBuilder: (_, __, ___) => page,
//         transitionsBuilder: (_, animation, secondaryAnimation, child) {
//           // Slide from left to right (like pop)
//           final offsetAnimation = Tween<Offset>(
//             begin: const Offset(-1.0, 0.0),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

//           return SlideTransition(position: offsetAnimation, child: child);
//         },
//       ),
//     );
//   }

//   /// PushReplacement with same pop-like animation
//   static void pushReplacementLikePop(BuildContext context, Widget page) {
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 250), // faster
//         pageBuilder: (_, __, ___) => page,
//         transitionsBuilder: (_, animation, secondaryAnimation, child) {
//           final offsetAnimation = Tween<Offset>(
//             begin: const Offset(-1.0, 0.0),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

//           return SlideTransition(position: offsetAnimation, child: child);
//         },
//       ),
//     );
//   }
// }

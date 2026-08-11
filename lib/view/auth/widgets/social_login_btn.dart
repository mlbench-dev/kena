// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

// class SocialLoginBtn extends StatelessWidget {
//   const SocialLoginBtn({super.key, required this.type, required this.onTap});
//   final String type; //apple / google
//   final VoidCallback onTap;
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 36.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(AppRadiuses.mediumRadius),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               type == 'apple'
//                   ? Assets.icons.appleLogo.svg(height: 24.h)
//                   : Assets.icons.googleIcon.svg(height: 24.h),
//               SizedBox(width: 8.w),
//               Text(
//                 type == 'apple'
//                     ? 'Apple'
//                     : Platform.isAndroid
//                     ? 'Sign In with Google'
//                     : 'Google',
//                 style: context.typography.body.copyWith(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16.sp,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

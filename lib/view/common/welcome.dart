// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/services/common/auth_service.dart';

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Center(
//           child: Column(
//             children: [
//               const Spacer(),
//               Row(
//                 children: [
//                   SizedBox(width: 74.w),
//                   // Assets.icons.play.svg(),
//                 ],
//               ),
//               SizedBox(height: 26.h),
//               Text(
//                 'kena',
//                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 42.sp),
//               ),
//               SizedBox(height: 26.h),
//               RichText(
//                 text: TextSpan(
//                   // 1. Define the base style for the entire text
//                   style: context.typography.body.copyWith(fontSize: 14.sp),
//                   children: <TextSpan>[
//                     // 2. The main body of the text (inherits the base style)
//                     const TextSpan(text: 'Discover, Track, Savour, '),
//                     // 3. The highlighted word 'Vendor'
//                     TextSpan(
//                       text: 'Vendor',
//                       style: context.typography.body.copyWith(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w700,
//                         color: context.colors.buttonPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 'Your Guide to Local Flavours!',
//                 style: context.typography.body.copyWith(fontSize: 14.sp),
//               ),
//               const Spacer(),
//               MyButton(
//                 label: 'Get Started',
//                 onPressed: () {
//                   AuthService.gotoProfileTypeSelection(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

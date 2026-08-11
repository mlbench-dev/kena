// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/components/colored_rich_text.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_pinput.dart';
// import 'package:kena_emotional_journey/app/components/my_text_button.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/services/common/auth_service.dart';

// class AccountVerificationSheet extends StatefulWidget {
//   const AccountVerificationSheet({
//     required this.email,
//     required this.isVendor,
//     super.key,
//   });
//   final String email;
//   final bool isVendor;

//   @override
//   State<AccountVerificationSheet> createState() =>
//       _AccountVerificationSheetState();
// }

// class _AccountVerificationSheetState extends State<AccountVerificationSheet> {
//   final pinController = TextEditingController();
//   final authService = AuthService();
//   bool isResendAvailable = false;
//   int remainingTime = 60;
//   Timer? _timer;
//   bool isLoading = false;
//   bool isSendingOtp = false;

//   void _startTimer() {
//     setState(() {
//       isResendAvailable = false;
//       remainingTime = 60;
//     });

//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingTime == 0) {
//         setState(() => isResendAvailable = true);
//         timer.cancel();
//       } else {
//         setState(() => remainingTime--);
//       }
//     });
//   }

//   Future<void> _sendOrResendOTP() async {
//     setState(() => isSendingOtp = true);
//     await authService.resendSignupOtp(context, widget.email).then((_) {
//       _startTimer();
//       if (mounted) {
//         setState(() => isSendingOtp = false);
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     pinController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ColoredRichText(first: "Account", second: " Verification"),
//             SizedBox(height: 7.h),
//             ColoredRichText(
//               first:
//                   "Please enter the verification code that we have sent on your email",
//               second: ' ${widget.email}',
//               // firstColor: context.colors.textDarkGreen.withValues(alpha: .60),
//               // secondColor: context.colors.textDarkGreen,
//               firstColor: context.colors.primary.withValues(alpha: .60),
//               secondColor: context.colors.primary,
//               firstFontSize: 15.sp,
//               secondFontSize: 15.sp,
//               firstFontWeight: FontWeight.w500,
//               secondFontWeight: FontWeight.w500,
//             ),
//             SizedBox(height: 50.h),
//             MyPinput(
//               controller: pinController,
//               enabled: !isLoading,
//               onChanged: (value) => setState(() {}),
//             ),
//             SizedBox(height: 15.h),
//             MyTextButton(
//               label: isResendAvailable
//                   ? 'Resend OTP'
//                   : 'Resend OTP in $remainingTime s',
//               onPressed: isResendAvailable && !isLoading && !isSendingOtp
//                   ? _sendOrResendOTP
//                   : null,
//             ),
//             SizedBox(height: 90.h),
//             MyButton(
//               label: 'Verify',
//               isLoading: isLoading,
//               onPressed: pinController.text.length < 4
//                   ? null
//                   : () async {
//                       setState(() => isLoading = true);
//                       await authService
//                           .verifyOtp(
//                             context: context,
//                             email: widget.email,
//                             otp: pinController.text,
//                             // isVendor: widget.isVendor,
//                           )
//                           .then((_) {
//                             if (mounted) {
//                               setState(() => isLoading = false);
//                             }
//                           });
//                     },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

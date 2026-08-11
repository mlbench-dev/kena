import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_pinput.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService authService = AuthService();
  final pinController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  bool isResendAvailable = false;
  int remainingTime = 60;
  bool isSendingOtp = false;
  bool isOtpSent = false;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      isResendAvailable = false;
      remainingTime = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        setState(() => isResendAvailable = true);
        timer.cancel();
      } else {
        setState(() => remainingTime--);
      }
    });
  }

  // Future<void> _sendOrResendOTP() async {
  //   setState(() => isSendingOtp = true);
  //   await authService
  //       .sendForgotOtp(context: context, email: emailController.text)
  //       .then((_) {
  //         isOtpSent = true;
  //         _startTimer();
  //         if (mounted) {
  //           setState(() => isSendingOtp = false);
  //         }
  //       });
  // }
  Future<void> _sendOrResendOTP() async {
    final email = emailController.text.trim();

    // ✅ Check empty email
    if (email.isEmpty) {
      context.flushBarErrorMessage(
        message: "Email is required",
        position: FlushbarPosition.TOP,
      );
      return;
    }

    // ✅ Check valid email
    if (!email.emailValidator()) {
      context.flushBarErrorMessage(
        message: "Enter a valid email address",
        position: FlushbarPosition.TOP,
      );
      return;
    }

    setState(() => isSendingOtp = true);
    await authService
        .sendForgotOtp(context: context, email: emailController.text)
        .then((_) {
          isOtpSent = true;
          _startTimer();
          if (mounted) {
            setState(() => isSendingOtp = false);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    // _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.w),
            child: BackButton(color: context.colors.textPrimary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    'Forgot Password?',
                    style: context.typography.title.copyWith(
                      fontSize: 24.sp,
                      fontVariations: [const FontVariation("wght", 510)],
                      fontFamily: 'sfpro',
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    textAlign: TextAlign.center,
                    "Enter your email to reset your password and get back on track",
                    style: context.typography.subtitle.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                      // fontFamily: 'sfpro',
                      color: context.colors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Email Address',
                        style: context.typography.title.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'sfpro',
                        ),
                      ),
                      SizedBox(height: 6.h),
                      MyFormTextField(
                        isDark: false,
                        borderRadius: 8.r,
                        prefixIcon: Icon(
                          Icons.mail_rounded,
                          color: context.colors.textSecondary,
                        ),
                        hint: 'Enter your email',
                        controller: emailController,
                        // textCapitalization: TextCapitalization.none,
                        readOnly: isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required.';
                          } else if (!value.emailValidator()) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyTextButton(
                            fontSize: 16.sp,
                            label: !isOtpSent
                                ? 'Send OTP'
                                : isResendAvailable
                                ? 'Resend OTP'
                                : 'Resend OTP in $remainingTime s',
                            onPressed:
                                (!isOtpSent || isResendAvailable) &&
                                    !isLoading &&
                                    !isSendingOtp
                                ? _sendOrResendOTP
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 50.h),
                  MyPinput(
                    controller: pinController,
                    enabled: !isLoading,
                    onChanged: (value) => setState(() {}),
                  ),

                  SizedBox(height: 40.h),
                  MyButton(
                    label: 'Verify Code',
                    isLoading: isLoading,
                    onPressed: pinController.text.length < 4
                        ? null
                        : () async {
                            // Navigator.pushNamed(
                            //   context,
                            //   RoutesName.resetPassword,
                            // );
                            // context.flushBarErrorMessage(
                            //   message: "Incorrect OTP, Please Try Again",
                            //   position: FlushbarPosition.BOTTOM,
                            //   margin: EdgeInsets.symmetric(
                            //     horizontal: 16.w,
                            //     vertical: 80.h,
                            //   ),
                            // );
                            setState(() => isLoading = true);
                            await authService
                                .verifyForgotOtp(
                                  context: context,
                                  email: emailController.text,
                                  code: pinController.text,
                                )
                                .then((_) {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                });
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

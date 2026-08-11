import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_pinput.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key, required this.email});

  final String email;

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final pinController = TextEditingController();
  bool isLoading = false;
  bool isResendAvailable = false;
  int remainingTime = 60;
  bool isSendingOtp = false;
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

  Future<void> _sendOrResendOTP() async {
    setState(() => isSendingOtp = true);
    await AuthService().resendSignupOtp(context, widget.email).then((_) {
      _startTimer();
      if (mounted) {
        setState(() => isSendingOtp = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
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
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    'Email Verification',
                    style: context.typography.title.copyWith(
                      fontSize: 24.sp,
                      fontVariations: [const FontVariation("wght", 510)],
                      fontFamily: 'sfpro',
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: context.typography.subtitle.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        // fontFamily: 'sfpro',
                        color: context.colors.textSecondary.withOpacity(0.8),
                      ),
                      children: [
                        TextSpan(
                          text:
                              "We have sent you a verification code to your given email ",
                          style: context.typography.subtitle.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                            // fontFamily: 'sfpro',
                            color: context.colors.textSecondary.withOpacity(
                              0.8,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: widget.email,
                          // text: "ahmad123@gmail.com",
                          style: context.typography.subtitle.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                            fontFamily: 'sfpro',
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),
                  MyPinput(
                    controller: pinController,
                    enabled: !isLoading,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 15.h),
                  MyTextButton(
                    fontSize: 16.sp,
                    label: isResendAvailable
                        ? 'Resend code'
                        : 'Resend OTP in $remainingTime s',
                    onPressed: isResendAvailable && !isLoading && !isSendingOtp
                        ? _sendOrResendOTP
                        : null,
                  ),
                  Spacer(),
                  MyButton(
                    label: 'Continue',
                    isLoading: isLoading,
                    onPressed: pinController.text.length < 4
                        ? null
                        : () async {
                            // context.flushBarErrorMessage(
                            //   message: "Incorrect OTP, Please Try Again",
                            //   position: FlushbarPosition.BOTTOM,
                            //   margin: EdgeInsets.symmetric(
                            //     horizontal: 16.w,
                            //     vertical: 80.h,
                            //   ),
                            // );
                            setState(() => isLoading = true);
                            await AuthService()
                                .verifyOtp(
                                  context: context,
                                  email: widget.email,
                                  otp: pinController.text,
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

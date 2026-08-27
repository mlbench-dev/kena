import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/native_liquid_glass_apple_button.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/app_constants.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/app/utils/legal_links.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/o_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final OAuthService _oAuthService = OAuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  bool isChecked = false;
  bool isAppleLoading = false;
  bool isGoogleLoading = false;
  bool isLoading = false;
  bool get _isFormFilled =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  late final TapGestureRecognizer _termsTapRecognizer = TapGestureRecognizer()
    ..onTap = () => openLegalUrl(context, ExternalLinks.kenaTermsAndConditions);

  @override
  void initState() {
    super.initState();
    fillFormForTesting();
    emailController.addListener(_onTextChange);
    passwordController.addListener(_onTextChange);
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  void fillFormForTesting() {
    if (kDebugMode) {
      emailController.text = 'muhmmadumair3233@gmail.com';
      passwordController.text = 'Pakistan@123';
    }
  }

  Future<void> _handleAppleLogin() async {
    if (isAppleLoading) return;

    setState(() {
      isAppleLoading = true;
    });

    try {
      await _oAuthService.appleAuth(context);
    } finally {
      if (mounted) {
        setState(() {
          isAppleLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (isGoogleLoading) return;

    setState(() {
      isGoogleLoading = true;
    });

    try {
      await _oAuthService.googleAuth(context);
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 25.w, 16.w, 16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Kena',
                      style: context.typography.title.copyWith(
                        fontSize: 32.sp,
                        fontFamily: 'ZenAntiqueSoft',
                        color: context.colors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Welcome back!',
                      style: context.typography.title.copyWith(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'sfpro',
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      textAlign: TextAlign.center,
                      'Enter your Email and password to continue to your account',
                      style: context.typography.subtitle.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
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
                SizedBox(height: 24.h),
                Text(
                  'Password',
                  style: context.typography.title.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 6.h),
                MyFormTextField(
                  isDark: false,
                  borderRadius: 8.r,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Assets.icons.lock.svg(),
                  ),
                  obscureText: hidePassword,
                  controller: passwordController,
                  hint: 'Enter your password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    child: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility_rounded,
                      color: const Color(0xFF686868),
                    ),
                  ),
                  readOnly: isLoading,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Password is required.';
                  //   } else if (!value.passwordValidator()) {
                  //     return 'Password must contain at least one uppercase letter, one number, and one special character.';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {},
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.forgotPassword);
                    },
                    child: Text(
                      'Forgot password?',
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: context.colors.textPrimary,
                        fontVariations: [const FontVariation('wght', 510)],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: isChecked,
                        fillColor: WidgetStateProperty.all(Colors.transparent),
                        checkColor: context.colors.primary,
                        side: WidgetStateBorderSide.resolveWith(
                          (states) => BorderSide(
                            width: 1.5,
                            color: states.contains(WidgetState.selected)
                                ? context.colors.primary
                                : Colors.black54,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: context.typography.body.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Raleway',
                          color: context.colors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'I have read and agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            recognizer: _termsTapRecognizer,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                MyButton(
                  label: 'Continue',
                  isLoading: isLoading,
                  onPressed: isChecked && _isFormFilled && !isLoading
                      ? () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          if (mounted) {
                            setState(() => isLoading = true);
                          }
                          await _authService.userLogin(
                            context,
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      : null,
                ),
                SizedBox(height: 26.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: context.colors.primaryGradient,
                        ),
                        height: 1.5.h,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Or sign up with',
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                        fontFamily: 'Raleway',
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: context
                                .colors
                                .primaryGradient
                                .colors
                                .reversed
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // --- Previous circular Apple/Google sign-in row (kept for reference) ---
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Platform.isIOS
                //         ? Container(
                //             padding: EdgeInsets.all(10.w),
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               border: Border.all(
                //                 color: const Color(0xFFd0d0d0),
                //                 width: 1.w,
                //               ),
                //             ),
                //             child: CircleAvatar(
                //               backgroundColor: Colors.transparent,
                //               child: GestureDetector(
                //                 onTap: isAppleLoading
                //                     ? null
                //                     : _handleAppleLogin,
                //                 child: isAppleLoading
                //                     ? LoadingWidget(
                //                         size: 18.sp,
                //                         color: context.colors.primary,
                //                       )
                //                     : Assets.icons.apple.svg(),
                //               ),
                //             ),
                //           )
                //         : const SizedBox.shrink(),
                //     Platform.isIOS
                //         ? SizedBox(width: 25.w)
                //         : const SizedBox.shrink(),
                //     Container(
                //       padding: EdgeInsets.all(10.w),
                //       decoration: BoxDecoration(
                //         shape: BoxShape.circle,
                //         border: Border.all(
                //           color: const Color(0xFFd0d0d0),
                //           width: 1.w,
                //         ),
                //       ),
                //       child: GestureDetector(
                //         onTap: isGoogleLoading ? null : _handleGoogleLogin,
                //         child: CircleAvatar(
                //           backgroundColor: Colors.transparent,
                //           child: isGoogleLoading
                //               ? LoadingWidget(
                //                   size: 18.sp,
                //                   color: context.colors.primary,
                //                 )
                //               : Assets.icons.googleIcon.svg(),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Platform.isIOS) ...[
                      // --- Native Liquid Glass "Sign in with Apple" button,
                      // same circle size as the Google button below ---
                      SizedBox(
                        width: 60.w,
                        height: 60.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: isAppleLoading,
                              child: NativeLiquidGlassAppleButton(
                                width: 60.w,
                                height: 60.w,
                                onPressed: _handleAppleLogin,
                              ),
                            ),
                            if (isAppleLoading)
                              LoadingWidget(
                                size: 18.sp,
                                color: context.colors.primary,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25.w),
                    ],
                    Platform.isIOS
                        ? SizedBox(
                            width: 60.w,
                            height: 60.w,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 20,
                                    sigmaY: 20,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: isGoogleLoading
                                            ? null
                                            : _handleGoogleLogin,
                                        child: isGoogleLoading
                                            ? LoadingWidget(
                                                size: 18.sp,
                                                color: context.colors.primary,
                                              )
                                            : SizedBox(
                                                width: 22.w,
                                                height: 22.w,
                                                child: Assets.icons.googleIcon
                                                    .svg(),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFd0d0d0),
                                width: 1.w,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: isGoogleLoading
                                  ? null
                                  : _handleGoogleLogin,
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: isGoogleLoading
                                    ? LoadingWidget(
                                        size: 18.sp,
                                        color: context.colors.primary,
                                      )
                                    : Assets.icons.googleIcon.svg(),
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(height: 25.h),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: context.typography.body.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Raleway',
                        color: context.colors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Don’t have an account?? '),
                        TextSpan(
                          text: 'Create Account',
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: context.colors.textPrimary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(
                                context,
                                RoutesName.userSignup,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

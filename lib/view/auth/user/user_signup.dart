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

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isChecked = false;
  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isFormFilled = ValueNotifier(false);
  bool isLoading = false;
  bool isAppleLoading = false;
  bool isGoogleLoading = false;

  final _userNameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  late final TapGestureRecognizer _termsTapRecognizer = TapGestureRecognizer()
    ..onTap = () => openLegalUrl(context, ExternalLinks.kenaTermsAndConditions);

  @override
  void initState() {
    super.initState();
    fillFormForTesting();
    _userNameController.addListener(_updateButtonState);
    _aliasController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _userNameController.removeListener(_updateButtonState);
    _aliasController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _confirmPasswordController.removeListener(_updateButtonState);

    _userNameController.dispose();
    _aliasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsTapRecognizer.dispose();
    isFormFilled.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isFilled =
        _userNameController.text.trim().isNotEmpty &&
        _aliasController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty;
    isFormFilled.value = isFilled;
  }

  ///
  ///
  ///Auto Fill fields in debug mode only
  ///
  ///
  void fillFormForTesting() {
    if (kDebugMode) {
      _userNameController.text = 'Tester@123';
      _aliasController.text = 'Tester';
      _emailController.text = 'muhmmadumair3233@gmail.com';
      _passwordController.text = 'Pakistan@123';
      _confirmPasswordController.text = 'Pakistan@123';
      isFormFilled.value = true;
    }
  }

  final OAuthService _oAuthService = OAuthService();

  Future<void> _handleAppleSignup() async {
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

  Future<void> _handleGoogleSignup() async {
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
      isSafeArea: false,
      body: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          top: 40.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: BackButton(color: context.colors.textPrimary),
              ),
              SizedBox(height: 20.h),
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
                'Sign Up Your Account',
                style: context.typography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 26.sp,
                  // fontFamily: 'SFProDisplay',
                  fontVariations: [FontVariation('wght', 590)],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Add your basic account details below'",
                style: context.typography.title.copyWith(
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 42.h),
                    Text(
                      'Username',
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        fontFamily: "Raleway",
                      ),
                    ),
                    SizedBox(height: 6.h),
                    MyFormTextField(
                      isDark: false,
                      hint: 'Enter Your Username',
                      prefixIcon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20.r,
                        child: Assets.icons.userRounded.svg(
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
                      controller: _userNameController,
                      readOnly: isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required.';
                        } else if (!value.usernameValidator()) {
                          return 'Use only letters, numbers, periods, and underscores. Spaces are not allowed.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),
                    Text(
                      'Alias Name',
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        fontFamily: "Raleway",
                      ),
                    ),
                    SizedBox(height: 6.h),
                    MyFormTextField(
                      isDark: false,
                      hint: 'Enter Your Alias Name',
                      prefixIcon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20.r,
                        child: Assets.icons.userRounded.svg(
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
                      controller: _aliasController,
                      readOnly: isLoading,
                    ),

                    SizedBox(height: 20.h),
                    Text(
                      'Email Address',
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        fontFamily: "Raleway",
                      ),
                    ),
                    SizedBox(height: 6.h),
                    MyFormTextField(
                      isDark: false,
                      // textCapitalization: TextCapitalization.none,
                      hint: 'Enter Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20.r,
                        child: Assets.icons.letter.svg(
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
                      controller: _emailController,
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

                    SizedBox(height: 20.h),
                    Text(
                      'Password',
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        fontFamily: "Raleway",
                      ),
                    ),
                    SizedBox(height: 6.h),
                    MyFormTextField(
                      isDark: false,
                      hint: 'Enter password',
                      obscureText: hidePassword,
                      prefixIcon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20.r,
                        child: Assets.icons.lock.svg(width: 30.w, height: 30.h),
                      ),
                      controller: _passwordController,
                      readOnly: isLoading,
                      focusNode: _passwordFocusNode,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF686868),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        } else if (!value.passwordValidator()) {
                          return 'Password must contain 8 characters and at least one uppercase letter, one number, and one special character.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Confirm Password',
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                        fontFamily: "Raleway",
                      ),
                    ),
                    SizedBox(height: 6.h),
                    MyFormTextField(
                      isDark: false,
                      hint: 'Re-enter Password',
                      controller: _confirmPasswordController,
                      obscureText: hideConfirmPassword,
                      prefixIcon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20.r,
                        child: Assets.icons.lock.svg(width: 30.w, height: 30.h),
                      ),
                      readOnly: isLoading,
                      focusNode: _confirmPasswordFocusNode,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hideConfirmPassword = !hideConfirmPassword;
                          });
                        },
                        child: Icon(
                          hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF686868),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm Password is required.';
                        } else if (value != _passwordController.text) {
                          return 'Confirm Password does not match Password.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: isChecked,
                            // Keeps the background hollow
                            fillColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            // Color of the tick mark
                            checkColor: context.colors.primary,
                            // Explicitly defines the border for both checked and unchecked states
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
                              fontFamily: "Raleway",
                              color: context.colors.textSecondary,
                            ),
                            children: [
                              const TextSpan(
                                text: 'I have read and agree to the ',
                              ),
                              TextSpan(
                                text: 'Terms and Conditions',
                                recognizer: _termsTapRecognizer,
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: context
                                      .colors
                                      .textPrimary, // Ensures underline matches text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: isFormFilled,
                      builder: (_, isFilled, _) {
                        return MyButton(
                          textColor: context.colors.background,
                          label: 'Sign Up',
                          isLoading: isLoading,
                          onPressed: isChecked && isFilled && !isLoading
                              ? () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setState(() => isLoading = true);
                                  await AuthService()
                                      .userSignup(
                                        context: context,
                                        username: _userNameController.text
                                            .trim(),
                                        aliasName: _aliasController.text.trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                      )
                                      .then((_) {
                                        if (mounted) {
                                          setState(() => isLoading = false);
                                        }
                                      });
                                  //   Navigator.pushNamed(
                                  //     context,
                                  //     RoutesName.emailVerification,
                                  //   );
                                }
                              : null,
                        );
                      },
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
                            fontFamily: "Raleway",
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
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.white70,
                            height: 1.5.h,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Sign Up With',
                          style: context.typography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            color: Colors.white70,
                            height: 1.5.h,
                          ),
                        ),
                      ],
                    ),
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
                                    onPressed: _handleAppleSignup,
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
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
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
                                                : _handleGoogleSignup,
                                            child: isGoogleLoading
                                                ? LoadingWidget(
                                                    size: 18.sp,
                                                    color:
                                                        context.colors.primary,
                                                  )
                                                : SizedBox(
                                                    width: 22.w,
                                                    height: 22.w,
                                                    child: Assets
                                                        .icons
                                                        .googleIcon
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
                                      : _handleGoogleSignup,
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
                    SizedBox(height: 26.h),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: context.typography.body.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily:
                                "Raleway", // Matches your previous text style
                          ),
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: context.colors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.textPrimary,
                                decorationThickness: 1.5,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Add your login navigation here
                                  debugPrint("Login tapped");
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.login,
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
            ],
          ),
        ),
      ),
    );
  }
}

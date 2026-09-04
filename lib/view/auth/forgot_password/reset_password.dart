import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.email, required this.otp});
  final String email;
  final String otp;
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final pinController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isFormFilled = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Form(
        key: _formKey,
        child: Column(
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
                      'Reset Password',
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
                      "Create a new password to access your account",
                      style: context.typography.subtitle.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        // fontFamily: 'sfpro',
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: context.typography.title.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'sfpro',
                          ),
                        ),
                        SizedBox(height: 6.h),
                        MyFormTextField(
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
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: hidePassword,
                          isDark: false,
                          borderRadius: 8.r,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),

                            child: Assets.icons.lock.svg(),
                          ),
                          hint: 'Enter Password',
                          controller: passwordController,
                          // textCapitalization: TextCapitalization.none,
                          readOnly: isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required.';
                            } else if (!value.passwordValidator()) {
                              return 'Password must contain 8 characters and at least one uppercase letter, one number, and one special character.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          'Re-type Password',
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
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: hideConfirmPassword,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Assets.icons.lock.svg(),
                          ),
                          hint: 'Enter Password',
                          controller: confirmPasswordController,
                          // textCapitalization: TextCapitalization.none,
                          readOnly: isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password is required.';
                            } else if (value != passwordController.text) {
                              return 'Confirm Password does not match Password.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    // SizedBox(height: 50.h),
                    // MyPinput(
                    //   controller: pinController,
                    //   enabled: !isLoading,
                    //   onChanged: (value) => setState(() {}),
                    // ),
                    SizedBox(height: 40.h),
                    MyButton(
                      label: 'Save',
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => isLoading = true);

                              await AuthService()
                                  .resetPassword(
                                    context: context,
                                    newPassword: passwordController.text.trim(),
                                    email: widget.email,
                                    code: widget.otp,
                                  )
                                  .then((_) {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  })
                                  .catchError((e) {
                                    setState(() => isLoading = false);

                                    context.flushBarErrorMessage(
                                      message: e.toString(),
                                      position: FlushbarPosition.TOP,
                                    );
                                  });
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

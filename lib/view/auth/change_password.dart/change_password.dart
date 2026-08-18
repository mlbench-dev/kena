import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/l10n/l10n.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authService = AuthService();

  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  bool hideOldPassword = true;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          context.l10n.auth_change_password,
          style: context.typography.title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              SizedBox(height: 36.h),
              Text(
                'Old Password',
                style: context.typography.title.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 10.h),
              MyFormTextField(
                textColor: context.colors.textPrimary,
                hint: 'Enter password',
                obscureText: hideOldPassword,
                readOnly: isLoading,
                controller: oldPasswordController,
                // textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required.';
                  }
                  return null;
                },
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      hideOldPassword = !hideOldPassword;
                    });
                  },
                  child: Icon(
                    hideOldPassword ? Icons.visibility_off : Icons.visibility,
                    color: context.colors.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'New Password',
                style: context.typography.title.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 10.h),
              MyFormTextField(
                textColor: context.colors.textPrimary,
                obscureText: hidePassword,
                hint: 'Enter password',
                readOnly: isLoading,
                controller: newPasswordController,
                // textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required.';
                  } else if (!value.passwordValidator()) {
                    return 'Password must contain 8 characters and at least one uppercase letter, one number, and one special character.';
                  }
                  return null;
                },
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  child: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: context.colors.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Retype New Password',
                style: context.typography.title.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 10.h),
              MyFormTextField(
                textColor: context.colors.textPrimary,
                hint: 'Enter password',
                obscureText: hideConfirmPassword,
                readOnly: isLoading,
                controller: confirmPasswordController,
                // textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm Password is required.';
                  } else if (value != newPasswordController.text) {
                    return 'Confirm Password does not match Password.';
                  }
                  return null;
                },
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
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.w),
        child: MyButton(
          label: 'Submit',
          isLoading: isLoading,
          onPressed: () async {
            if (isLoading) return;
            if (!formKey.currentState!.validate()) return;
            if (mounted) {
              setState(() => isLoading = true);
            }
            await _authService.changePassword(
              context: context,
              oldPassword: oldPasswordController.text,
              newPassword: newPasswordController.text,
              onSuccess: () => Navigator.pop(context),
            );
            if (mounted) {
              setState(() => isLoading = false);
            }

            debugPrint('Submit button pressed');
          },
        ),
      ),
    );
  }
}

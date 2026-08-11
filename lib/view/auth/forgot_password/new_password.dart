// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena/app/components/my_button.dart';
// import 'package:kena/app/components/my_form_text_field.dart';
// import 'package:kena/app/components/my_scaffold.dart';
// import 'package:kena/app/utils/extensions/context_extensions.dart';
// import 'package:kena/app/utils/extensions/validations_exception.dart';
// import 'package:kena/services/common/auth_service.dart';

// class NewPasswordScreen extends StatefulWidget {
//   const NewPasswordScreen({
//     super.key,
//     required this.email,
//     required this.otp,
//     required this.isVendor,
//   });
//   final String email;
//   final String otp;
//   final bool isVendor;
//   @override
//   State<NewPasswordScreen> createState() => _NewPasswordScreenState();
// }

// class _NewPasswordScreenState extends State<NewPasswordScreen> {
//   bool hidePassword = true;
//   bool hideConfirmPassword = true;

//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   bool isFormFilled = false;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     passwordController.addListener(_updateButtonState);
//     confirmPasswordController.addListener(_updateButtonState);
//   }

//   @override
//   void dispose() {
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _updateButtonState() {
//     final isFilled =
//         passwordController.text.trim().isNotEmpty &&
//         confirmPasswordController.text.trim().isNotEmpty;
//     if (mounted) {
//       setState(() {
//         isFormFilled = isFilled;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'kena',
//           style: context.typography.title.copyWith(
//             fontSize: 32.sp,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 36.h),
//                       Text(
//                         'Forgot Password?',
//                         style: context.typography.title.copyWith(
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       SizedBox(height: 6.h),
//                       Text(
//                         'Enter new password to secure your account.',
//                         style: context.typography.body.copyWith(
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                       SizedBox(height: 36.h),
//                       Text(
//                         'New Password',
//                         style: context.typography.title.copyWith(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 10.h),
//                       //password
//                       MyFormTextField(
//                         obscureText: hidePassword,
//                         hint: 'Enter password',
//                         controller: passwordController,
//                         suffixIcon: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               hidePassword = !hidePassword;
//                             });
//                           },
//                           child: Icon(
//                             hidePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                         ),

//                         keyboardType: TextInputType.visiblePassword,
//                         textCapitalization: TextCapitalization.none,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Password is required.';
//                           } else if (!value.passwordValidator()) {
//                             return 'Password must contain at least one uppercase letter, one number, and one special character.';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 24.h),
//                       Text(
//                         'Confirm Password',
//                         style: context.typography.title.copyWith(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 10.h),
//                       //confirm password
//                       MyFormTextField(
//                         obscureText: hideConfirmPassword,
//                         hint: 'Enter password',
//                         controller: confirmPasswordController,
//                         suffixIcon: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               hideConfirmPassword = !hideConfirmPassword;
//                             });
//                           },
//                           child: Icon(
//                             hideConfirmPassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                         ),
//                         keyboardType: TextInputType.visiblePassword,
//                         textCapitalization: TextCapitalization.none,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Confirm Password is required.';
//                           } else if (value != passwordController.text) {
//                             return 'Confirm Password does not match Password.';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SafeArea(
//                 top: false,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 20),

//                   // child: MyButton(
//                   //   label: 'Submit',
//                   //   onPressed: () {
//                   //     debugPrint('Submit button pressed');
//                   //   },
//                   // ),
//                   child: MyButton(
//                     label: 'Submit',
//                     onPressed: isFormFilled && !isLoading
//                         ? () async {
//                             if (!_formKey.currentState!.validate()) return;
//                             if (mounted) {
//                               setState(() => isLoading = true);
//                             }

//                             await AuthService()
//                                 .resetPassword(
//                                   context: context,
//                                   isUser: !widget.isVendor,
//                                   newPassword: passwordController.text.trim(),
//                                   email: widget.email,
//                                   otp: widget.otp,
//                                 )
//                                 .then((_) {
//                                   if (mounted) {
//                                     setState(() => isLoading = false);
//                                   }
//                                 });
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

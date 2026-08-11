// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena/app/utils/extensions/context_extensions.dart';
// import 'my_button.dart';

// class MyDialogBox extends StatefulWidget {
//   final Widget leadingIcon; // required
//   final String title; // required
//   final String subtitle;
//   final void Function() onCancel;
//   final void Function(int selectedNumber) onConfirm;

//   const MyDialogBox({
//     super.key,
//     required this.leadingIcon,
//     required this.title,
//     required this.subtitle,
//     required this.onCancel,
//     required this.onConfirm,
//   });

//   @override
//   State<MyDialogBox> createState() => _MyDialogBoxState();
// }

// class _MyDialogBoxState extends State<MyDialogBox> {
//   int selectedNumber = 0; // default no selection

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Container(
//         width: 300.w,
//         height: 257.h,
//         padding: EdgeInsets.all(15.w),
//         decoration: BoxDecoration(
//           color: Color(0xFFfefdf9),
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top row: icon + title + subtitle
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 widget.leadingIcon,
//                 SizedBox(width: 15.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 10.h),
//                     Text(
//                       widget.title,
//                       style: context.typography.body.copyWith(
//                         color: context.colors.textPrimary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 5.h),
//                     Text(
//                       widget.subtitle,
//                       style: context.typography.subtitle.copyWith(
//                         fontSize: 14.sp,
//                         color: context.colors.textSecondary.withOpacity(0.7),
//                         fontVariations: const [FontVariation('wght', 400.0)],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             SizedBox(height: 30.h),

//             // Number boxes row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(5, (index) {
//                 int number = index + 1;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedNumber = number;
//                     });
//                   },
//                   child: NumberBox(
//                     number: number,
//                     isSelected: selectedNumber == number,
//                   ),
//                 );
//               }),
//             ),

//             SizedBox(height: 10.h),

//             // Low / Intense labels
//             Padding(
//               padding: EdgeInsets.only(left: 5.w),
//               child: Row(
//                 children: [
//                   Text(
//                     "Low",
//                     style: context.typography.subtitle.copyWith(
//                       fontSize: 12.sp,
//                       color: context.colors.textSecondary.withOpacity(0.7),
//                     ),
//                   ),
//                   Spacer(),
//                   Text(
//                     "Intense",
//                     style: context.typography.subtitle.copyWith(
//                       fontSize: 12.sp,
//                       color: context.colors.textSecondary.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 15.h),

//             // Buttons row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   width: 130.w,
//                   height: 48.h,
//                   child: MyButton(
//                     label: "Cancel",
//                     backgroundColor: Color(0xFFf5f5f5),
//                     textColor: context.colors.textPrimary,
//                     onPressed: widget.onCancel,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 130.w,
//                   height: 48.h,
//                   child: MyButton(
//                     label: "Confirm",
//                     textColor: context.colors.background,
//                     onPressed: () => widget.onConfirm(selectedNumber),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // NumberBox with selection color
// class NumberBox extends StatelessWidget {
//   final int number;
//   final bool isSelected;

//   const NumberBox({super.key, required this.number, this.isSelected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 42.w,
//       height: 42.h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.r),
//         color: isSelected ? Color(0xFFc8e6c9) : Color(0xFFf5f5f5),
//         border: Border.all(
//           color: isSelected ? Color(0xFF81c784) : Color(0xFFe0e0e0),
//           width: 2.w,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           number.toString(),
//           style: TextStyle(
//             color: context.colors.textPrimary,
//             fontWeight: FontWeight.bold,
//             fontSize: 16.sp,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';

class MyDialogBox extends StatelessWidget {
  const MyDialogBox({required this.child, super.key});

  final Widget child;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      builder: (_) => MyDialogBox(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFfefdf9),
          borderRadius: BorderRadius.circular(AppRadiuses.extraLargeRadius),
        ),
        child: child,
      ),
    );
  }
}

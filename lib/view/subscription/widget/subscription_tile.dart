// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/model/subscription.dart';
// import 'package:kena_emotional_journey/view/subscription/subscription.dart';

// class SubscriptionOption extends StatefulWidget {
//   const SubscriptionOption({
//     required this.subscriptionOptions,
//     required this.onIndexChanged,
//     super.key,
//   });

//   final void Function(int) onIndexChanged;
//   final List<Subscription> subscriptionOptions;

//   @override
//   SubscriptionOptionState createState() => SubscriptionOptionState();
// }

// class SubscriptionOptionState extends State<SubscriptionOption> {
//   SubscriptionModel sub = SubscriptionModel();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: widget.subscriptionOptions.asMap().entries.map((entry) {
//         final int index = entry.key;
//         final Subscription option = entry.value;
//         return Column(
//           children: [
//             SubscriptionTile(
//               label: option.label,
//               price: option.priceString,
//               discount: option.discount,
//               discountComparedTo: option.discountComparedTo,
//               index: index,
//               selectedIndex: sub.selectedIndex,
//               onSelect: (index) {
//                 setState(() => sub.selectedIndex = index);
//                 widget.onIndexChanged(index);
//               },
//               duration: option.duration,
//             ),
//             if (index != widget.subscriptionOptions.length - 1)
//               SizedBox(height: 10.h),
//           ],
//         );
//       }).toList(),
//     );
//   }
// }

// class SubscriptionTile extends StatelessWidget {
//   const SubscriptionTile({
//     required this.label,
//     required this.price,
//     required this.index,
//     required this.selectedIndex,
//     required this.onSelect,
//     required this.duration,
//     this.discount,
//     this.discountComparedTo,
//     super.key,
//   });

//   final String label;
//   final String duration;
//   final String price;
//   final int? discount;
//   final String? discountComparedTo;
//   final int index;
//   final int? selectedIndex;
//   final void Function(int) onSelect;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
//       child: InkWell(
//         onTap: () => onSelect(index), // Select tile
//         borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
//         child: BackdropFilter(
//           filter: ui.ImageFilter.blur(
//             sigmaX: 34,
//             sigmaY: 34,
//             tileMode: TileMode.decal,
//           ),
//           child: Stack(
//             children: [
//               Container(
//                 alignment: Alignment.center,
//                 height: 75.h,
//                 decoration: BoxDecoration(
//                   color: context.colors.white.withValues(alpha: .1),
//                   borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
//                   border: Border.all(
//                     color: selectedIndex == index
//                         ? context.colors.mainGreenLight
//                         : context.colors.white.withValues(alpha: .1),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Radio<int>(
//                         value: index,
//                         groupValue: selectedIndex,
//                         onChanged: (value) {
//                           onSelect(value!);
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(vertical: 11.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 label,
//                                 style: context.typography.subtitle.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: context.colors.white
//                                       .withValues(alpha: .5),
//                                 ),
//                               ),
//                               Text(
//                                 ' ($duration)',
//                                 style: context.typography.subtitle.copyWith(
//                                   fontSize: 12.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: context.colors.white
//                                       .withValues(alpha: .5),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             price,
//                             style: context.typography.title.copyWith(
//                               fontSize: 22.sp,
//                               fontWeight: FontWeight.w600,
//                               color: context.colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       if (discount != null)
//                         Stack(
//                           children: [
//                             Assets.images.riban.svg(),
//                             Positioned(
//                               top: 0,
//                               bottom: 10,
//                               right: 0,
//                               left: 0,
//                               child: Align(
//                                 child: Text(
//                                   '${discount!}%',
//                                   style: context.typography.label.copyWith(
//                                     fontSize: 13.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: context.colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       SizedBox(height: 4.h),
//                       if (discountComparedTo != null)
//                         Text(
//                           discountComparedTo!,
//                           style: context.typography.subtitle.copyWith(
//                             fontSize: 11.sp,
//                             color: context.colors.white.withValues(alpha: .6),
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(width: 8.w),
//                 ],
//               ),
//               SizedBox(width: 12.w),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

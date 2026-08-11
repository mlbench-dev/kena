// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:kena_emotional_journey/app/components/colored_rich_text.dart';
// import 'package:kena_emotional_journey/app/components/loading_widget.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/components/my_text_button.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/env.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/l10n/l10n.dart';
// import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
// import 'package:kena_emotional_journey/services/payment/iap_services.dart';
// import 'package:kena_emotional_journey/services/payment/subscription_services.dart';

// import 'package:kena_emotional_journey/view/subscription/widget/my_scaffold.dart';
// import 'package:kena_emotional_journey/view/subscription/widget/subscription_tile.dart';

// class SubscriptionScreen extends StatefulWidget {
//   const SubscriptionScreen({
//     super.key,
//     this.showSkip = false,
//   });
//   final bool showSkip;

//   @override
//   State<SubscriptionScreen> createState() => _SubscriptionScreenState();
// }

// bool isSubscriptionButtonLoading = false;
// bool isLoaded = true;

// //default subscriptions
// List<Subscription> subscriptions = [
//   Subscription(
//     label: 'Yearly',
//     duration: '12 Months auto-renewing',
//     priceString: r'$67.99',
//     discount: 60,
//     discountComparedTo: 'Less Compared To Weekly',
//     price: 67.99,
//   ),
//   Subscription(
//     label: 'Monthly',
//     duration: '30 days auto-renewing',
//     priceString: r'$6.99',
//     discount: 50,
//     discountComparedTo: 'Less Compared To Weekly',
//     price: 6.99,
//   ),
//   Subscription(
//     label: 'Weekly',
//     duration: '7 days auto-renewing',
//     priceString: r'$2.99',
//     price: 2.99,
//   ),
// ];

// class _SubscriptionScreenState extends State<SubscriptionScreen> {
//   final _iapServices = InAppPurchaseServices();
//   final _sessionController = SessionController();

//   //initial payment id
//   String priceId = Env.stripeYearly;

//   //Update prices
//   //When subscriptions are loaded from IAP, update the localized prices
//   void updatePrices(List<ProductDetails> subs) {
//     for (final sub in subs) {
//       if (sub.title.contains('Year')) {
//         subscriptions[0] = Subscription(
//           label: 'Yearly',
//           duration: '12 Months auto-renewing',
//           priceString: '${sub.currencySymbol} ${sub.rawPrice}',
//           discount: 60,
//           discountComparedTo: 'Less Compared To Weekly',
//           price: sub.rawPrice,
//         );
//       } else if (sub.title.contains('Month')) {
//         subscriptions[1] = Subscription(
//           label: 'Monthly',
//           duration: '30 days auto-renewing',
//           priceString: '${sub.currencySymbol} ${sub.rawPrice}',
//           discount: 50,
//           discountComparedTo: 'Less Compared To Weekly',
//           price: sub.rawPrice,
//         );
//       } else if (sub.title.contains('Week')) {
//         subscriptions[2] = Subscription(
//           label: 'Weekly',
//           duration: '7 days auto-renewing',
//           priceString: '${sub.currencySymbol} ${sub.rawPrice}',
//           price: sub.rawPrice,
//         );
//       }
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }
//   //END: Update prices

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       setState(() {
//         isSubscriptionButtonLoading = false;
//       });
//     }
//     _iapServices
//       ..loadSubscriptions(
//         (loadingStatus) {
//           if (mounted) {
//             setState(() {
//               isLoaded = loadingStatus;
//             });
//           }
//         },
//         updatePrices,
//       ) //load Subscripions for in app purchase
//       ..startListeningToPurchaseUpdates(
//         context,
//         isSignupFlow: widget.showSkip,
//       );
//   }

//   @override
//   void dispose() {
//     _iapServices.closeSubscriptionStream();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: !widget.showSkip
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios),
//                 color: !isSubscriptionButtonLoading
//                     ? context.colors.mainGreenLight
//                     : Colors.grey,
//                 onPressed: !isSubscriptionButtonLoading
//                     ? () => Navigator.pop(context)
//                     : null,
//               )
//             : const SizedBox.shrink(),
//         actions: [
//           if (widget.showSkip)
//             MyTextButton(
//               isDark: false,
//               fontSize: 16.sp,
//               label: context.l10n.sub_skip,
//               onPressed: () {
//                 showInfoDialog(context);
//               },
//             ),
//           SizedBox(width: 16.w),
//         ],
//       ),
//       body: isLoaded
//           ? SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Assets.images.logo.onlyLogo.svg(
//                       height: 50.h,
//                       fit: BoxFit.fitHeight,
//                     ),
//                     SizedBox(height: 10.h),
//                     Text(
//                       context.l10n.sub_now_title,
//                       style: context.typography.title.copyWith(
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.w700,
//                         color: context.colors.white,
//                         height: 1.21,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       context.l10n.sub_now_subtitle,
//                       style: context.typography.title.copyWith(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w500,
//                         color: context.colors.white.withValues(alpha: .7),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     //prices
//                     SubscriptionOption(
//                       // subscriptionOptions: SubscriptionModel.subscriptions,
//                       subscriptionOptions: subscriptions,
//                       onIndexChanged: (index) {
//                         _sessionController.setselectedSubscriptionIndex(index);
//                         switch (index) {
//                           case 0:
//                             if (mounted) {
//                               setState(() {
//                                 // _iapServices.selectedSubscription = 0;
//                                 // debugPrint(
//                                 //     'SELECTED SUBSCRIPTION INDEX: ${_iapServices.selectedSubscription}');
//                                 priceId = Env.stripeYearly;
//                               });
//                             }

//                           // break;
//                           case 1:
//                             if (mounted) {
//                               setState(() {
//                                 // _iapServices.selectedSubscription = 1;
//                                 // debugPrint(
//                                 //     'SELECTED SUBSCRIPTION INDEX: ${_sessionController.selectedSubscriptionIndex}');
//                                 priceId = Env.stripeMonthly;
//                               });
//                             }

//                           // break;
//                           case 2:
//                             if (mounted) {
//                               setState(() {
//                                 // _iapServices.selectedSubscription = 2;
//                                 // debugPrint(
//                                 //     'SELECTED SUBSCRIPTION INDEX: ${_sessionController.selectedSubscriptionIndex}');
//                                 priceId = Env.stripeWeekly;
//                               });
//                             }

//                           // break;
//                         }
//                       },
//                     ),
//                     //END: prices
//                     SizedBox(height: 12.h),
//                     Text(
//                       context.l10n.sub_what_is_include,
//                       style: context.typography.title.copyWith(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: context.colors.mainGreenLight,
//                       ),
//                     ),
//                     SizedBox(height: 10.h),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Align(
//                           alignment: Alignment.topCenter,
//                           child: Icon(
//                             Icons.check,
//                             size: 24.w,
//                             color: context.colors.mainGreenLight,
//                           ),
//                         ),
//                         SizedBox(width: 8.w),
//                         Flexible(
//                           child: ColoredRichText(
//                             first: context.l10n.sub_discounts_title,
//                             second: context.l10n.sub_discounts_subtitle,
//                             firstColor: context.colors.white,
//                             secondColor:
//                                 context.colors.white.withValues(alpha: .5),
//                             firstFontSize: 13.sp,
//                             secondFontSize: 13.sp,
//                             firstFontWeight: FontWeight.w600,
//                             secondFontWeight: FontWeight.w500,
//                             textAlign: TextAlign.start,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 14.h),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Align(
//                           alignment: Alignment.topCenter,
//                           child: Icon(
//                             Icons.check,
//                             size: 24.w,
//                             color: context.colors.mainGreenLight,
//                           ),
//                         ),
//                         SizedBox(width: 8.w),
//                         Flexible(
//                           child: ColoredRichText(
//                             first: context.l10n.sub_unlimited_title,
//                             second: context.l10n.sub_unlimited_subtitle,
//                             firstColor: context.colors.white,
//                             secondColor:
//                                 context.colors.white.withValues(alpha: .5),
//                             firstFontSize: 13.sp,
//                             secondFontSize: 13.sp,
//                             firstFontWeight: FontWeight.w600,
//                             secondFontWeight: FontWeight.w500,
//                             textAlign: TextAlign.start,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         MyTextButton(
//                           isDark: false,
//                           label: 'Terms of Service',
//                           onPressed: () {
//                             SettingService().sageLaunchUrl(
//                               ExternalLinks.appleTermsOfService,
//                             );
//                           },
//                         ),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'and',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                         SizedBox(width: 8.w),
//                         MyTextButton(
//                           isDark: false,
//                           label: 'Privacy Policy',
//                           onPressed: () {
//                             SettingService().sageLaunchUrl(
//                               'https://sage-frontend-eta.vercel.app/privacy_policies',
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 32.h),
//                     MyButton(
//                       isLoading: isSubscriptionButtonLoading,
//                       label: context.l10n.subscribe,
//                       onPressed: () async {
//                         WidgetsBinding.instance.addPostFrameCallback((_) async {
//                           await SubscriptionScreenService()
//                               .handleSubscribeButton(
//                             context,
//                             priceId,
//                             isSignupFlow: widget.showSkip,
//                             updateLoading: () {
//                               if (context.mounted) {
//                                 setState(
//                                   () {
//                                     isSubscriptionButtonLoading =
//                                         !isSubscriptionButtonLoading;
//                                   },
//                                 );
//                               }
//                             },
//                           );
//                         });
//                       },
//                     ),
//                     SizedBox(height: 16.h),
//                   ],
//                 ),
//               ),
//             )
//           : const Center(
//               child: LoadingWidget(
//                 color: Colors.white,
//               ),
//             ),
//     );
//   }
// }

// // Subscrition Model
// class SubscriptionModel {
//   SubscriptionModel({this.selectedIndex}) {
//     // If selectedIndex is null and the list is not empty, assign the first item
//     //by default
//     if (selectedIndex == null && subscriptions.isNotEmpty) {
//       selectedIndex = 0;
//     }
//   }

//   int? selectedIndex;

//   // Select a subscription by index
//   void selectSubscription(int index) {
//     if (index >= 0 && index < subscriptions.length) {
//       selectedIndex = index;
//     }
//   }

//   // Get the selected subscription
//   Subscription? get selectedSubscription {
//     if (selectedIndex != null && selectedIndex! < subscriptions.length) {
//       return subscriptions[selectedIndex!];
//     }
//     return null;
//   }
// }

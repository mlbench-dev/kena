// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_dialog.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/components/my_text_field.dart';
// import 'package:kena_emotional_journey/app/routes/routes_name.dart';
// import 'package:kena_emotional_journey/app/utils/app_url.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/model/user/user_home_model.dart';
// import 'package:kena_emotional_journey/model/emotions/emotions_list.dart';
// import 'package:kena_emotional_journey/services/user/user_home_service.dart';
// import 'package:kena_emotional_journey/view/home/widgets/intensity_circle_home.dart';
// import 'package:like_button/like_button.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// final UserHomeService userHomeService = UserHomeService();
// UserHomeModel? userHomeModel;

// String dayName = DateFormat('EEEE').format(DateTime.now());
// String restOfDate = DateFormat(', d MMM yyyy').format(DateTime.now());

// bool hasData = false;
// bool isChecked = false;
// bool isCheckedOne = false;
// bool isCheckedTwo = false;

// class _OnboardingScreenState extends State<OnboardingScreen>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _loadHomeData();
//   }

//   Future<void> _loadHomeData() async {
//     final data = await userHomeService.getUserDetails();
//     if (!mounted) return;
//     setState(() {
//       userHomeModel = data;
//       hasData = (data?.data?.isNotEmpty ?? false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return MyScaffold(
//       isSafeArea: false,
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               height: 140.h,
//               decoration: BoxDecoration(
//                 color: context.colors.primary,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15.w),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: context.colors.background,
//                       radius: 22.r,
//                       child: CircleAvatar(
//                         backgroundColor: context.colors.background,
//                         radius: 22.r,
//                         backgroundImage: NetworkImage(
//                           "https://images.unsplash.com/photo-1559568147-fef5fddb6905?q=80&w=1901&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10.w),
//                     Padding(
//                       padding: EdgeInsets.only(top: 40.h),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Good Morning, alex",
//                             style: context.typography.headline.copyWith(
//                               color: Colors.white,
//                               fontSize: 18.sp,
//                             ),
//                           ),
//                           Text(
//                             "Your emotional journey continues.",
//                             style: context.typography.label.copyWith(
//                               fontSize: 12.sp,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Spacer(),
//                     Assets.icons.notifications.svg(
//                       height: 40.h,
//                       width: 40.h,
//                       // colorFilter: const ColorFilter.mode(
//                       //   Colors.white,
//                       //   BlendMode.srcIn,
//                       // ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Icon(
//                           Icons.arrow_back_ios_new,
//                           color: context.colors.primary,
//                           size: 16,
//                         ),
//                         RichText(
//                           text: TextSpan(
//                             style: context.typography.label.copyWith(
//                               fontSize: 14.sp,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text: dayName,
//                                 style: context.typography.body.copyWith(
//                                   color: context.colors.textPrimary,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: restOfDate,
//                                 style: context.typography.body.copyWith(
//                                   color: Colors.grey,
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: context.colors.primary,
//                           size: 16,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   Container(
//                     padding: EdgeInsets.all(15.w),
//                     height: 330.h,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20.r),
//                       border: Border.all(color: Color(0xFFd0d0d0), width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               "Core Emotions",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: context.colors.textPrimary,
//                               ),
//                             ),
//                             Spacer(),
//                             Text(
//                               "Aspirational Emotions",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: context.colors.textPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10.h),
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.only(
//                                 top: 15.h,
//                                 bottom: 15.h,
//                                 left: 10.w,
//                               ),
//                               height: 200.h,
//                               width: 154.w,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(color: Color(0xFFc0d2c4)),
//                               ),
//                               child:
//                                   (hasData &&
//                                       (userHomeModel
//                                               ?.data
//                                               ?.first
//                                               .coreEmotions
//                                               ?.isNotEmpty ??
//                                           false))
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: userHomeModel!
//                                           .data!
//                                           .first
//                                           .coreEmotions!
//                                           .take(2)
//                                           .map(
//                                             (e) => Padding(
//                                               padding: EdgeInsets.only(
//                                                 bottom: 10.h,
//                                               ),
//                                               child: IntensityCircleHome(
//                                                 customSize: 65,
//                                                 intensity:
//                                                     e.intensityPercent ?? 0,
//                                                 centerWidget:
//                                                     EmotionsList.getEmojiByKey(
//                                                       e.key ?? '',
//                                                       fallbackEmoji: e.emoji,
//                                                     ),
//                                                 label:
//                                                     EmotionsList.getTitleByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                     )
//                                   : Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,

//                                       children: [
//                                         Assets.icons.oulineSadEmoji.svg(
//                                           width: 24.w,
//                                           height: 24.h,
//                                         ),
//                                         SizedBox(height: 20.h),
//                                         Text(
//                                           textAlign: TextAlign.center,
//                                           "You haven't selected your core emotions yet",
//                                           style: context.typography.subtitle
//                                               .copyWith(fontSize: 14.sp),
//                                         ),
//                                       ],
//                                     ),
//                             ),
//                             Spacer(),
//                             Container(
//                               padding: EdgeInsets.only(
//                                 top: 15.h,
//                                 bottom: 15.h,
//                                 left: 10.w,
//                               ),
//                               height: 200.h,
//                               width: 154.w,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(color: Color(0xFFc0d2c4)),
//                               ),
//                               child:
//                                   (hasData &&
//                                       (userHomeModel
//                                               ?.data
//                                               ?.first
//                                               .aspirationEmotions
//                                               ?.isNotEmpty ??
//                                           false))
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: userHomeModel!
//                                           .data!
//                                           .first
//                                           .aspirationEmotions!
//                                           .take(2)
//                                           .map(
//                                             (e) => Padding(
//                                               padding: EdgeInsets.only(
//                                                 bottom: 10.h,
//                                               ),
//                                               child: IntensityCircleHome(
//                                                 customSize: 65,
//                                                 intensity:
//                                                     e.intensityPercent ?? 0,
//                                                 centerWidget:
//                                                     EmotionsList.getEmojiByKey(
//                                                       e.key ?? '',
//                                                       fallbackEmoji: e.emoji,
//                                                     ),
//                                                 imageUrl: e.imageUrl != null
//                                                     ? (e.imageUrl!.startsWith(
//                                                             'http',
//                                                           )
//                                                           ? e.imageUrl
//                                                           : '${AppUrl.baseUrl}${e.imageUrl}')
//                                                     : null,
//                                                 label:
//                                                     EmotionsList.getTitleByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                     )
//                                   : Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Assets.icons.oulineSadEmoji.svg(
//                                           width: 24.w,
//                                           height: 24.h,
//                                         ),
//                                         SizedBox(height: 20.h),
//                                         Text(
//                                           textAlign: TextAlign.center,
//                                           "You haven't selected your aspirational emotions yet",
//                                           style: context.typography.subtitle
//                                               .copyWith(fontSize: 14.sp),
//                                         ),
//                                       ],
//                                     ),
//                             ),
//                           ],
//                         ),
//                         Spacer(),
//                         MyButton(
//                           fontWeight: FontWeight.w500,
//                           textColor: context.colors.background,
//                           fontSize: 15.sp,
//                           label: "Select emotions",
//                           onPressed: () {
//                             Navigator.of(
//                               context,
//                             ).pushNamed(RoutesName.coreEmotions);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 15.h),
//                   Padding(
//                     padding: EdgeInsets.only(left: 8.w),
//                     child: Text(
//                       "Daily Reflection",
//                       style: context.typography.body.copyWith(
//                         color: context.colors.textPrimary,
//                         fontSize: 17.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   Container(
//                     padding: EdgeInsets.all(15.w),
//                     height: 450.h,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Color(0xFFd0d0d0), width: 1),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           "Your forecast and daily log help build emotional awareness.",
//                           style: context.typography.subtitle.copyWith(
//                             fontSize: 13.sp,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               "Forecast",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: context.colors.textPrimary,
//                               ),
//                             ),
//                             SizedBox(width: 115.w),
//                             Text(
//                               "End of Day",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 15.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: context.colors.textPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10.h),
//                         Row(
//                           children: [
//                             // ── Forecast Column ──
//                             Container(
//                               padding: EdgeInsets.only(
//                                 top: 15.h,
//                                 bottom: 15.h,
//                                 left: 10.w,
//                               ),
//                               height: 200.h,
//                               width: 154.w,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(color: Color(0xFFc0d2c4)),
//                               ),
//                               child:
//                                   (hasData &&
//                                       (userHomeModel
//                                               ?.data
//                                               ?.first
//                                               .journal
//                                               ?.forecast
//                                               ?.emotions
//                                               ?.isNotEmpty ??
//                                           false))
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: userHomeModel!
//                                           .data!
//                                           .first
//                                           .journal!
//                                           .forecast!
//                                           .emotions!
//                                           .take(2)
//                                           .map(
//                                             (e) => Padding(
//                                               padding: EdgeInsets.only(
//                                                 bottom: 10.h,
//                                               ),
//                                               child: IntensityCircleHome(
//                                                 customSize: 65,
//                                                 intensity: e.intensityPercent,
//                                                 centerWidget:
//                                                     EmotionsList.getEmojiByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                                 label:
//                                                     EmotionsList.getTitleByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                     )
//                                   : Center(
//                                       child: Text(
//                                         textAlign: TextAlign.left,
//                                         "Forecast & plan todays emotions for better choices.",
//                                         style: context.typography.subtitle
//                                             .copyWith(fontSize: 14.sp),
//                                       ),
//                                     ),
//                             ),
//                             Spacer(),
//                             // ── End of Day Column ──
//                             Container(
//                               padding: EdgeInsets.only(
//                                 top: 15.h,
//                                 bottom: 15.h,
//                                 left: 10.w,
//                               ),
//                               height: 200.h,
//                               width: 154.w,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(color: Color(0xFFc0d2c4)),
//                               ),
//                               child:
//                                   (hasData &&
//                                       (userHomeModel
//                                               ?.data
//                                               ?.first
//                                               .journal
//                                               ?.reflection
//                                               ?.emotions
//                                               ?.isNotEmpty ??
//                                           false))
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: userHomeModel!
//                                           .data!
//                                           .first
//                                           .journal!
//                                           .reflection!
//                                           .emotions!
//                                           .take(2)
//                                           .map(
//                                             (e) => Padding(
//                                               padding: EdgeInsets.only(
//                                                 bottom: 10.h,
//                                               ),
//                                               child: IntensityCircleHome(
//                                                 customSize: 65,
//                                                 intensity: e.intensityPercent,
//                                                 centerWidget:
//                                                     EmotionsList.getEmojiByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                                 label:
//                                                     EmotionsList.getTitleByKey(
//                                                       e.key ?? '',
//                                                     ),
//                                               ),
//                                             ),
//                                           )
//                                           .toList(),
//                                     )
//                                   : Center(
//                                       child: Text(
//                                         textAlign: TextAlign.center,
//                                         "Did it go as forecast?",
//                                         style: context.typography.subtitle
//                                             .copyWith(fontSize: 14.sp),
//                                       ),
//                                     ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15.h),
//                         MyButton(
//                           fontWeight: FontWeight.w500,
//                           textColor: context.colors.background,
//                           fontSize: 15.sp,
//                           label: "Forecast today",
//                           onPressed: () {
//                             Navigator.pushNamed(
//                               context,
//                               RoutesName.forecastScreen,
//                             );
//                           },
//                         ),
//                         Spacer(),
//                         MyButton(
//                           fontWeight: FontWeight.w500,
//                           backgroundColor: Colors.transparent,
//                           textColor: context.colors.primary,
//                           fontSize: 15.sp,
//                           borderWidth: 1,
//                           borderColor: context.colors.primary,
//                           label: "End of Day Reflection",
//                           onPressed: () {
//                             Navigator.pushNamed(
//                               context,
//                               RoutesName.endDayReflection,
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 15.h),
//                   (hasData &&
//                           (userHomeModel?.data?.first.activities?.isNotEmpty ??
//                               false))
//                       ? Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Today's Activities",
//                                   style: context.typography.title.copyWith(
//                                     fontFamily: 'sfpro',
//                                   ),
//                                 ),
//                                 Text(
//                                   "View All",
//                                   style: context.typography.title.copyWith(
//                                     fontSize: 16.sp,
//                                     color: context.colors.primary,
//                                     fontFamily: 'sfpro',
//                                     decoration: TextDecoration.underline,
//                                     decorationColor: context.colors.textPrimary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10.h),
//                             Text(
//                               maxLines: 2,
//                               softWrap: true,
//                               "Actions to help achieve your goal...Tap checkbox to mark done",
//                               style: context.typography.subtitle.copyWith(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(height: 5.h),
//                             ...userHomeModel!.data!.first.activities!
//                                 .take(3)
//                                 .map(
//                                   (activity) => Padding(
//                                     padding: EdgeInsets.only(bottom: 5.h),
//                                     child: Container(
//                                       padding: EdgeInsets.all(5.w),
//                                       width: double.infinity,
//                                       height: 56.h,
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: context.colors.textSecondary
//                                               .withOpacity(0.3),
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                           8.r,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               activity.name ?? '',
//                                               style: context.typography.body
//                                                   .copyWith(
//                                                     fontSize: 14.sp,
//                                                     color: context
//                                                         .colors
//                                                         .textPrimary,
//                                                     fontWeight: FontWeight.w400,
//                                                     decoration:
//                                                         activity.completed
//                                                         ? TextDecoration
//                                                               .lineThrough
//                                                         : null,
//                                                   ),
//                                             ),
//                                           ),
//                                           Checkbox(
//                                             value: activity.completed,
//                                             fillColor: WidgetStateProperty.all(
//                                               !activity.completed
//                                                   ? Colors.transparent
//                                                   : context.colors.primary,
//                                             ),
//                                             checkColor:
//                                                 context.colors.background,
//                                             side:
//                                                 WidgetStateBorderSide.resolveWith(
//                                                   (states) => BorderSide(
//                                                     width: 1.5,
//                                                     color:
//                                                         states.contains(
//                                                           WidgetState.selected,
//                                                         )
//                                                         ? context.colors.primary
//                                                         : Colors.black54,
//                                                   ),
//                                                 ),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(5.r),
//                                             ),
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 activity.completed =
//                                                     value ?? false;
//                                               });
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                           ],
//                         )
//                       : Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 20.w,
//                             vertical: 12.h,
//                           ),
//                           height: 166.h,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(
//                               color: Color(0xFFd1d5dd),
//                               width: 2,
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Assets.images.icon.image(),
//                                   SizedBox(width: 10.w),
//                                   Text(
//                                     textAlign: TextAlign.center,
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2,
//                                     "Support your emotional journey",
//                                     style: context.typography.subtitle.copyWith(
//                                       fontSize: 16.sp,
//                                       color: context.colors.textPrimary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10.h),
//                               Text(
//                                 "Choose activities that help you move from where you are to where you want to be.",
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.left,
//                                 style: context.typography.subtitle.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                               Spacer(),
//                               MyButton(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 15.sp,
//                                 textColor: context.colors.background,
//                                 label: "Choose Activities",
//                                 onPressed: () async {
//                                   Navigator.pushNamed(
//                                     context,
//                                     RoutesName.chooseActivity,
//                                   ).then((_) {
//                                     _loadHomeData();
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                   SizedBox(height: 10.h),
//                   hasData
//                       ? SizedBox.shrink()
//                       : Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 20.w,
//                             vertical: 12.h,
//                           ),
//                           height: 150.h,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(
//                               color: Color(0xFFd1d5dd),
//                               width: 2,
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Assets.images.people.image(),
//                                   SizedBox(width: 10.w),
//                                   Text(
//                                     textAlign: TextAlign.center,
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2,
//                                     "Community Highlights",
//                                     style: context.typography.subtitle.copyWith(
//                                       fontSize: 16.sp,
//                                       color: context.colors.textPrimary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10.h),
//                               Text(
//                                 "You don't have to do this alone.",
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.left,
//                                 style: context.typography.subtitle.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                               Spacer(),
//                               MyButton(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 14.sp,
//                                 textColor: context.colors.background,
//                                 label: "Build a Commuity",
//                                 onPressed: () {
//                                   setState(() {});
//                                   MyDialogBox.show(
//                                     // isDismissible: true,
//                                     context,
//                                     child: CreateCommunityBottomSheet(),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                   // SizedBox(height: 10.h),
//                   Text(
//                     "Community Highlights",
//                     style: context.typography.title.copyWith(),
//                   ),
//                   SizedBox(height: 3.h),
//                   Text(
//                     "See updates from your support circle",
//                     style: context.typography.subtitle.copyWith(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   CommunityPostContainer(),
//                   SizedBox(height: 10.h),
//                   CommunityPostContainer(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CommunityPostContainer extends StatelessWidget {
//   const CommunityPostContainer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: context.colors.textSecondary.withOpacity(0.3),
//         ),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min, // Allows column to wrap content
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20.r,
//                 backgroundColor: const Color(0xFFfd9447),
//                 child: CircleAvatar(
//                   radius: 19.5.r,
//                   backgroundColor: context.colors.primary,
//                   backgroundImage: const CachedNetworkImageProvider(
//                     "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1760&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Sarah",
//                     style: context.typography.title.copyWith(
//                       fontVariations: [const FontVariation('wght', 530)],
//                       fontSize: 14.sp,
//                       fontFamily: "sfpro",
//                     ),
//                   ),
//                   Text(
//                     "Dec 2, 2025",
//                     style: context.typography.subtitle.copyWith(
//                       color: context.colors.textSecondary.withOpacity(0.6),
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12.sp,
//                       fontFamily: "sfpro",
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             "Sending a virtual hug 🤗",
//             style: context.typography.subtitle.copyWith(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           LikeButton(
//             mainAxisAlignment: MainAxisAlignment.start,
//             size: 20,
//             circleColor: const CircleColor(
//               start: Color(0xff00ddff),
//               end: Color(0xff0099cc),
//             ),
//             bubblesColor: const BubblesColor(
//               dotPrimaryColor: Color(0xff33b5e5),
//               dotSecondaryColor: Color(0xff0099cc),
//             ),
//             likeBuilder: (bool isLiked) {
//               return Icon(
//                 Icons.favorite_rounded,
//                 color: isLiked ? Colors.red : Colors.grey,
//                 size: 20.sp,
//               );
//             },
//             likeCount: 30,
//             countBuilder: (int? count, bool isLiked, String text) {
//               final color = isLiked ? Colors.red : Colors.grey;

//               if (count == null || count == 0) {
//                 return Text(
//                   "love",
//                   style: TextStyle(color: color, fontSize: 14.sp),
//                 );
//               }

//               return Text(
//                 text,
//                 style: TextStyle(color: color, fontSize: 14.sp),
//               );
//             },
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             "Add a Comment",
//             style: context.typography.subtitle.copyWith(
//               fontSize: 14.sp,
//               color: Colors.blue,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CreateCommunityBottomSheet extends StatefulWidget {
//   const CreateCommunityBottomSheet({super.key});

//   @override
//   State<CreateCommunityBottomSheet> createState() =>
//       _CreateCommunityBottomSheetState();
// }

// class _CreateCommunityBottomSheetState
//     extends State<CreateCommunityBottomSheet> {
//   // Keeping controllers here keeps OnboardingScreen clean
//   final nameController = TextEditingController();
//   final descController = TextEditingController();

//   @override
//   void dispose() {
//     nameController.dispose();
//     descController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future<void> createCommunity() async {
//       await userHomeService.createCommunity(
//         name: nameController.text,
//         description: descController.text,
//         context: context,
//       );
//     }

//     return SizedBox(
//       height: 560.h,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Handle bar
//             // Center(
//             //   child: Container(
//             //     height: 5.h,
//             //     width: 54.w,
//             //     decoration: BoxDecoration(
//             //       color: const Color(0xFF6b6e80),
//             //       borderRadius: BorderRadius.circular(10),
//             //     ),
//             //   ),
//             // ),
//             // SizedBox(height: 10.h),

//             // Header Section
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     "Create Your Personal Community",
//                     style: context.typography.body.copyWith(
//                       color: context.colors.textPrimary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 18.sp,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   Text(
//                     "Build a private emotional space for you and your trusted friends.",
//                     textAlign: TextAlign.center,
//                     style: context.typography.body.copyWith(
//                       color: context.colors.textSecondary,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // Input Fields
//             Text(
//               "Community Name",
//               style: context.typography.body.copyWith(
//                 color: context.colors.textPrimary,
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             MyTextField(
//               controller: nameController,
//               hint: "Enter your community name",
//               fillColor: Colors.transparent,
//               borderColor: context.colors.textSecondary.withOpacity(0.3),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               "Choose a meaningful name for your group.",
//               style: context.typography.body.copyWith(
//                 color: context.colors.textSecondary,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               "Description",
//               style: context.typography.body.copyWith(
//                 color: context.colors.textPrimary,
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             MyTextField(
//               controller: descController,
//               maxLines: 6,
//               hint: "Write a short description about your community’s purpose.",
//               fillColor: Colors.transparent,
//               borderColor: context.colors.textSecondary.withOpacity(0.3),
//             ),

//             SizedBox(height: 20.h),

//             // Action Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: MyButton(
//                     fontWeight: FontWeight.w500,
//                     label: "Cancel",
//                     onPressed: () => Navigator.pop(context),
//                     backgroundColor: Colors.transparent,
//                     borderWidth: 1,
//                     borderColor: context.colors.primary,
//                     textColor: context.colors.primary,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: MyButton(
//                     fontWeight: FontWeight.w500,
//                     label: "Create",
//                     onPressed: () async {
//                       if (nameController.text.isEmpty ||
//                           descController.text.isEmpty) {
//                         context.flushBarErrorMessage(
//                           message: "Please fill all the fields",
//                         );
//                         return;
//                       }
//                       await createCommunity();
//                       if (context.mounted) {
//                         setState(() {});
//                         MyBottomSheet.show(
//                           isDismissible: true,
//                           context,
//                           child: const CommunityIsReady(),
//                         );
//                       }
//                     },
//                     backgroundColor: context.colors.primary,
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

// class CommunityIsReady extends StatefulWidget {
//   const CommunityIsReady({super.key});

//   @override
//   State<CommunityIsReady> createState() => _CommunityIsReadyState();
// }

// class _CommunityIsReadyState extends State<CommunityIsReady> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//       child: SizedBox(
//         height: 270.h,
//         child: Column(
//           children: [
//             Center(
//               child: Assets.images.partyPopper.image(width: 48, height: 67),
//             ),
//             SizedBox(height: 10.h),
//             Center(
//               child: Text(
//                 "Your Community is ready",
//                 style: context.typography.title.copyWith(
//                   color: context.colors.textPrimary,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Center(
//               child: Text(
//                 "Invite friends to start building a supportive space.",
//                 textAlign: TextAlign.center,
//                 style: context.typography.body.copyWith(
//                   color: context.colors.textSecondary,
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16.sp,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             MyButton(
//               textColor: context.colors.background,
//               fontWeight: FontWeight.w500,
//               label: "Invite Friends",
//               onPressed: () {
//                 setState(() {});
//                 MyDialogBox.show(
//                   context,
//                   child: SizedBox(
//                     height: 370.h,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 15.w,
//                         vertical: 15.h,
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: Text(
//                               "Invite Friends",
//                               style: context.typography.title.copyWith(
//                                 color: context.colors.textPrimary,
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           Center(
//                             child: Text(
//                               textAlign: TextAlign.center,
//                               "Share your private link and grow together.",
//                               style: context.typography.body.copyWith(
//                                 color: context.colors.textSecondary,
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           Text(
//                             "Your Private Invite Link",
//                             style: context.typography.body.copyWith(
//                               color: context.colors.textPrimary,
//                               fontSize: 15.sp,
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: MyTextField(
//                                   hint:
//                                       "https://app.example.com/invite/f8i8f-d7qye",
//                                   readOnly: true,
//                                   fillColor: Colors.transparent,
//                                   borderColor: context.colors.textSecondary
//                                       .withOpacity(0.3),
//                                 ),
//                               ),
//                               SizedBox(width: 10.w),
//                               GestureDetector(
//                                 onTap: () {},
//                                 child: Container(
//                                   height: 50.h,
//                                   width: 50.w,
//                                   decoration: BoxDecoration(
//                                     color: context.colors.primary,
//                                     borderRadius: BorderRadius.circular(10.r),
//                                   ),
//                                   child: Icon(
//                                     Icons.copy,
//                                     color: context.colors.background,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10.h),
//                           Text(
//                             "Your Private Invite Link",
//                             style: context.typography.body.copyWith(
//                               color: context.colors.textPrimary,
//                               fontSize: 15.sp,
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: MyTextField(
//                                   hint:
//                                       "https://app.example.com/invite/f8i8f-d7qye",
//                                   readOnly: true,
//                                   fillColor: Colors.transparent,
//                                   borderColor: context.colors.textSecondary
//                                       .withOpacity(0.3),
//                                 ),
//                               ),
//                               SizedBox(width: 10.w),
//                               GestureDetector(
//                                 onTap: () {},
//                                 child: Container(
//                                   height: 50.h,
//                                   width: 50.w,
//                                   decoration: BoxDecoration(
//                                     color: context.colors.primary,
//                                     borderRadius: BorderRadius.circular(10.r),
//                                   ),
//                                   child: Icon(
//                                     Icons.copy,
//                                     color: context.colors.background,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 15.h),
//                           MyButton(
//                             label: "Share Via Other Apps",
//                             fontWeight: FontWeight.w400,
//                             icon: Assets.icons.share.svg(width: 22, height: 22),
//                             onPressed: () {},
//                             borderColor: context.colors.background,
//                             backgroundColor: Color(0xFFf3f4f6),
//                             textColor: context.colors.textPrimary,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

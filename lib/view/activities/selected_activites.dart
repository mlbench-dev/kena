// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:kena_emotional_journey/app/components/loading_widget.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/routes/routes_name.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/model/activites/activities_model.dart';
// import 'package:kena_emotional_journey/services/user/user_home_service.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

// class SelectedActivitiesScreen extends StatefulWidget {
//   const SelectedActivitiesScreen({super.key});

//   @override
//   State<SelectedActivitiesScreen> createState() =>
//       _SelectedActivitiesScreenState();
// }

// class _SelectedActivitiesScreenState extends State<SelectedActivitiesScreen> {
//   final UserHomeService _service = UserHomeService();
//   bool _isLoading = true;
//   ActivitiesModel? _model;
//   final List<Activity> _deleteSelections = [];
//   bool _isDeleteMode = false;
//   bool _isDeleting = false;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     final result = await _service.getActivities(context: context);
//     if (mounted) {
//       setState(() {
//         _model = result;
//         _isLoading = false;
//         _isDeleteMode = false;
//         _deleteSelections.clear();
//       });
//     }
//   }

//   void _toggleDeleteSelection(Activity activity) {
//     setState(() {
//       final exists = _deleteSelections.any((a) => a.name == activity.name);
//       if (exists) {
//         _deleteSelections.removeWhere((a) => a.name == activity.name);
//       } else {
//         _deleteSelections.add(activity);
//       }
//     });
//   }

//   Future<void> _confirmDelete() async {
//     if (_deleteSelections.isEmpty) {
//       setState(() => _isDeleteMode = false);
//       return;
//     }
//     setState(() => _isDeleting = true);

//     for (final activity in List<Activity>.from(_deleteSelections)) {
//       if (activity.name != null) {
//         final success = await _service.removeActivity(
//           name: activity.name!,
//           context: context,
//         );
//         if (success && mounted) {
//           setState(() {
//             _data?.activities?.removeWhere((a) => a.name == activity.name);
//           });
//         }
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _deleteSelections.clear();
//         _isDeleteMode = false;
//         _isDeleting = false;
//       });
//     }
//   }

//   Future<void> _toggleActivity(Activity activity) async {
//     if (activity.name == null || _data?.day == null) return;

//     DateTime day;
//     try {
//       day = DateTime.parse(_data!.day!);
//     } catch (_) {
//       day = DateTime.now();
//     }

//     final previousCompletedState = activity.completed ?? false;
//     final newCompletedState = !previousCompletedState;

//     // Optimistic UI Update
//     setState(() {
//       final index =
//           _data?.activities?.indexWhere((a) => a.name == activity.name) ?? -1;
//       if (index != -1) {
//         _data!.activities![index] = Activity(
//           name: activity.name,
//           frequency: activity.frequency,
//           isCustom: activity.isCustom,
//           completed: newCompletedState,
//         );
//       }
//     });

//     final success = await _service.updateActivity(
//       context: context,
//       name: activity.name!,
//       completed: newCompletedState,
//       day: day,
//       isCustom: activity.isCustom ?? false,
//     );

//     if (!success) {
//       // Revert if failed
//       setState(() {
//         final revertIndex =
//             _data?.activities?.indexWhere((a) => a.name == activity.name) ?? -1;
//         if (revertIndex != -1) {
//           _data!.activities![revertIndex] = Activity(
//             name: activity.name,
//             frequency: activity.frequency,
//             isCustom: activity.isCustom,
//             completed: previousCompletedState,
//           );
//         }
//       });
//     }
//   }

//   // Getters
//   ActivityData? get _data =>
//       _model?.data?.isNotEmpty == true ? _model!.data!.first : null;
//   List<Activity> get _todaysActivities => _data?.activities ?? [];

//   int get _completedCount =>
//       _todaysActivities.where((a) => a.completed == true).length;
//   int get _totalCount => _todaysActivities.length;

//   double get _progress =>
//       _totalCount == 0 ? 0.0 : (_completedCount / _totalCount);
//   String get _displayDate {
//     if (_data?.day != null) {
//       try {
//         DateTime date = DateTime.parse(_data!.day!);
//         return DateFormat('EEEE, MMMM d').format(date);
//       } catch (e) {
//         return _data!.day!;
//       }
//     }
//     return DateFormat('EEEE, MMMM d').format(DateTime.now());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: _isLoading
//             ? Center(
//                 child: LoadingAnimationWidget.staggeredDotsWave(
//                   color: context.colors.primary,
//                   size: 45,
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: Icon(
//                             Icons.arrow_back_ios_new,
//                             color: context.colors.textPrimary,
//                           ),
//                         ),
//                         Expanded(
//                           child: Center(
//                             child: Text(
//                               "Activities",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 20.sp,
//                                 fontWeight: FontWeight.w600,
//                                 fontFamily: "sfpro",
//                               ),
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () => Navigator.pushNamed(
//                             context,
//                             RoutesName.homeScreen,
//                           ),
//                           child: Assets.icons.homeIcon.svg(
//                             height: 40.h,
//                             width: 40.w,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20.h),

//                     // Progress Card
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(20.w),
//                       height: 126.h,
//                       decoration: BoxDecoration(
//                         color: context.colors.background,
//                         border: Border.all(
//                           color: context.colors.textSecondary.withValues(
//                             alpha: 0.2,
//                           ),
//                         ),
//                         borderRadius: BorderRadius.circular(16.r),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Daily Progress",
//                                 style: context.typography.headline.copyWith(
//                                   fontSize: 18.sp,
//                                   fontWeight: FontWeight.w600,
//                                   fontFamily: "sfpro",
//                                 ),
//                               ),
//                               Text(
//                                 "${(_progress * 100).toInt()}%",
//                                 style: context.typography.headline.copyWith(
//                                   fontSize: 26.sp,
//                                   color: context.colors.primary,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _displayDate,
//                                 style: context.typography.headline.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: context.colors.textSecondary
//                                       .withValues(alpha: 0.9),
//                                 ),
//                               ),
//                               Text(
//                                 "$_completedCount/$_totalCount done",
//                                 style: context.typography.headline.copyWith(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: context.colors.textSecondary
//                                       .withValues(alpha: 0.9),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 20.h),

//                     // Empty State
//                     if (_todaysActivities.isEmpty)
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(20.w),
//                         height: 201.h,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: context.colors.textSecondary.withValues(
//                               alpha: 0.2,
//                             ),
//                           ),
//                           borderRadius: BorderRadius.circular(16.r),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "No Activities Selected",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.w600,
//                                 fontFamily: "sfpro",
//                               ),
//                             ),
//                             Text(
//                               textAlign: TextAlign.center,
//                               "Choose activities to track your daily progress",
//                               style: context.typography.headline.copyWith(
//                                 fontSize: 14.sp,
//                                 color: context.colors.textSecondary.withValues(
//                                   alpha: 0.9,
//                                 ),
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(height: 20.h),
//                             SizedBox(
//                               height: 45.h,
//                               width: 165.w,
//                               child: MyButton(
//                                 label: "Choose Activities",
//                                 onPressed: () async {
//                                   await Navigator.pushNamed(
//                                     context,
//                                     RoutesName.chooseActivity,
//                                     arguments: {
//                                       'isToday': true,
//                                     },
//                                   );
//                                   await _load();
//                                 },
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     // Todays Tasks List
//                     if (_todaysActivities.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           Text(
//                             "Today's Tasks",
//                             style: context.typography.headline.copyWith(
//                               fontSize: 17.sp,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: "sfpro",
//                             ),
//                           ),
//                           const Spacer(),
//                           if (_isDeleteMode) ...[
//                             // Cancel button
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _isDeleteMode = false;
//                                   _deleteSelections.clear();
//                                 });
//                               },
//                               child: Icon(
//                                 Icons.close,
//                                 color: context.colors.textSecondary,
//                                 size: 26.sp,
//                               ),
//                             ),
//                             SizedBox(width: 12.w),
//                             // Confirm delete button
//                             GestureDetector(
//                               onTap: _isDeleting ? null : _confirmDelete,
//                               child: _isDeleting
//                                   ? SizedBox(
//                                       width: 22.sp,
//                                       height: 22.sp,
//                                       child:
//                                           LoadingAnimationWidget.staggeredDotsWave(
//                                             color: context.colors.error,
//                                             size: 20,
//                                           ),
//                                     )
//                                   : Icon(
//                                       Icons.delete_forever_outlined,
//                                       color: _deleteSelections.isEmpty
//                                           ? context.colors.error.withValues(
//                                               alpha: 0.4,
//                                             )
//                                           : context.colors.error,
//                                       size: 26.sp,
//                                     ),
//                             ),
//                           ] else
//                             // Enter delete mode button
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() => _isDeleteMode = true);
//                               },
//                               child: Icon(
//                                 Icons.delete_forever_outlined,
//                                 color: context.colors.error,
//                                 size: 26.sp,
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 10.h),

//                       ..._todaysActivities.map((activity) {
//                         final bool isDone = activity.completed == true;
//                         final bool isSelectedForDelete = _deleteSelections.any(
//                           (a) => a.name == activity.name,
//                         );

//                         // Border colour depends on mode
//                         final Color borderColor = _isDeleteMode
//                             ? (isSelectedForDelete
//                                   ? context.colors.error
//                                   : context.colors.error.withValues(
//                                       alpha: 0.25,
//                                     ))
//                             : (isDone
//                                   ? context.colors.primary
//                                   : context.colors.textSecondary.withValues(
//                                       alpha: 0.3,
//                                     ));

//                         return Padding(
//                           padding: EdgeInsets.only(bottom: 12.h),
//                           child: GestureDetector(
//                             onTap: _isDeleteMode
//                                 ? () => _toggleDeleteSelection(activity)
//                                 : () => _toggleActivity(activity),
//                             child: Container(
//                               width: double.infinity,
//                               padding: EdgeInsets.all(16.w),
//                               decoration: BoxDecoration(
//                                 color: _isDeleteMode
//                                     ? (isSelectedForDelete
//                                           ? context.colors.error.withValues(
//                                               alpha: 0.06,
//                                             )
//                                           : Colors.transparent)
//                                     : (isDone
//                                           ? const Color(0xFFf0f9f5)
//                                           : Colors.transparent),
//                                 border: Border.all(
//                                   color: borderColor,
//                                   width: isSelectedForDelete || isDone ? 2 : 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(16.r),
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     _isDeleteMode
//                                         ? (isSelectedForDelete
//                                               ? Icons.check_circle
//                                               : Icons.circle_outlined)
//                                         : (isDone
//                                               ? Icons.check_circle
//                                               : Icons.circle_outlined),
//                                     color: _isDeleteMode
//                                         ? (isSelectedForDelete
//                                               ? context.colors.error
//                                               : context.colors.textSecondary
//                                                     .withValues(alpha: 0.5))
//                                         : (isDone
//                                               ? context.colors.primary
//                                               : context.colors.textSecondary),
//                                     size: 32.sp,
//                                   ),
//                                   SizedBox(width: 10.w),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         activity.name ?? "",
//                                         style: context.typography.headline
//                                             .copyWith(
//                                               fontSize: 15.sp,
//                                               fontWeight: FontWeight.w600,
//                                               color: _isDeleteMode
//                                                   ? (isSelectedForDelete
//                                                         ? context.colors.error
//                                                         : context
//                                                               .colors
//                                                               .textPrimary)
//                                                   : (isDone
//                                                         ? context.colors.primary
//                                                         : context
//                                                               .colors
//                                                               .textPrimary),
//                                               fontFamily: "sfpro",
//                                             ),
//                                       ),
//                                       SizedBox(height: 5.h),
//                                       Text(
//                                         activity.frequency ?? "",
//                                         style: context.typography.headline
//                                             .copyWith(
//                                               fontSize: 12.sp,
//                                               fontWeight: FontWeight.w400,
//                                               color: context
//                                                   .colors
//                                                   .textSecondary
//                                                   .withValues(alpha: 0.9),
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                   const Spacer(),
//                                   if (!_isDeleteMode && isDone) ...[
//                                     Icon(
//                                       Icons.check,
//                                       color: context.colors.primary,
//                                       size: 20.sp,
//                                     ),
//                                     SizedBox(width: 5.w),
//                                     Text(
//                                       "Done",
//                                       style: context.typography.headline
//                                           .copyWith(
//                                             fontSize: 12.sp,
//                                             fontWeight: FontWeight.w600,
//                                             color: context.colors.primary,
//                                           ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }),

//                       // Show completion banner if all are done
//                       if (_todaysActivities.isNotEmpty &&
//                           _completedCount == _totalCount) ...[
//                         SizedBox(height: 15.h),
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16.w),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: context.colors.primary),
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   "🎉 Amazing! You've completed all your activities today! Your commitment to wellness is inspiring.",
//                                   style: context.typography.headline.copyWith(
//                                     fontSize: 13.sp,
//                                     fontWeight: FontWeight.w400,
//                                     color: context.colors.primary,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],

//                       if (_todaysActivities.isNotEmpty && _completedCount == 0)
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(16.w),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: context.colors.primary),
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   "✨ Start your day by completing your first activity. You've got this!",
//                                   style: context.typography.headline.copyWith(
//                                     fontSize: 13.sp,
//                                     fontWeight: FontWeight.w400,
//                                     color: context.colors.primary,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       SizedBox(height: 20.h),
//                       MyButton(
//                         label: "Add Activities",
//                         onPressed: () async {
//                           await Navigator.pushNamed(
//                             context,
//                             RoutesName.chooseActivity,
//                             arguments: {
//                               'isToday': true,
//                             },
//                           );
//                           await _load();
//                         },
//                       ),
//                       SizedBox(height: 30.h),
//                     ],
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

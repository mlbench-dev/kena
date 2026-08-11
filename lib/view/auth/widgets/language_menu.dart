// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

// class Language {
//   Language(this.code, this.name);
//   final String code;
//   final String name;
// }

// class LanguageMenu extends StatelessWidget {
//   const LanguageMenu({
//     required this.selectedLanguage,
//     required this.onSelected,
//     super.key,
//   });
//   final Language selectedLanguage;
//   final ValueChanged<Language> onSelected;

//   @override
//   Widget build(BuildContext context) {
//     final languages = [Language('en', 'English'), Language('es', 'Spanish')];

//     return PopupMenuButton<Language>(
//       color: Colors.white,
//       onSelected: onSelected,
//       offset: Offset(0, 40.w),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       itemBuilder: (context) => languages
//           .map(
//             (lang) => PopupMenuItem<Language>(
//               value: lang,
//               child: Row(
//                 children: [
//                   Text(
//                     lang.name,
//                     style: context.typography.body.copyWith(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: context.colors.textOnLight,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//           .toList(),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(width: 8.w),
//           Text(
//             selectedLanguage.name,
//             style: context.typography.body.copyWith(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: Colors.white,
//             size: 28.w,
//           ),
//         ],
//       ),
//     );
//   }
// }

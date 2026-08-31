// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kena_emotional_journey/app/components/my_button.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/services/common/auth_service.dart';
// import 'package:kena_emotional_journey/services/common/connectivity service.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:kena_emotional_journey/provider/connectivity_provider.dart';

// class NoConnectionScreen extends StatefulWidget {
//   const NoConnectionScreen({super.key});

//   @override
//   State<NoConnectionScreen> createState() => _NoConnectionScreenState();
// }

// class _NoConnectionScreenState extends State<NoConnectionScreen> {
//   bool isLoading = false;
//   final _authService = AuthService();
//   @override
//   Widget build(BuildContext context) {
//     return MyScaffold(
//       body: isLoading
//           ? Center(
//               child: LoadingAnimationWidget.staggeredDotsWave(
//                 color: context.colors.primary,
//                 size: 45,
//               ),
//             )
//           : Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const Spacer(),
//                     Icon(
//                       Icons.signal_wifi_connected_no_internet_4,
//                       size: 80,
//                       color: context.colors.textPrimary,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'No Connection',
//                       style: context.typography.title.copyWith(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18.sp,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       textAlign: TextAlign.center,
//                       'Please connect to the internet and press the "Retry" button below.',
//                       style: context.typography.body.copyWith(fontSize: 14.sp),
//                     ),
//                     const Spacer(),
//                     MyButton(
//                       isLoading: isLoading,
//                       label: 'Retry',
//                       onPressed: () async {
//                         setState(() {
//                           isLoading = true;
//                         });
//                         final online = await ConnectivityService.instance
//                             .checkConnection();
//                         if (!mounted) return;
//                         if (!online) {
//                           setState(() {
//                             isLoading = false;
//                           });
//                           return;
//                         }
//                         // Avoid flicker: suppress stream updates briefly
//                         ConnectivityService.instance.suppress(
//                           const Duration(seconds: 2),
//                         );
//                         // Mark online first so overlay disappears immediately
//                         context.read<ConnectivityProvider>().updateConnection(
//                           true,
//                         );
//                         await _authService.checkAuthentication(context);
//                         if (!mounted) return;
//                         setState(() {
//                           isLoading = false;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

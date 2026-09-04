import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/delete_account_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/no_internet_dialog.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/app_constants.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/legal_links.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/connectivity_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:kena_emotional_journey/view/profile/widgets/profile_menu_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionController _sessionController = SessionController();
  final AuthService _authService = AuthService();
  final SubscriptionCacheService _subscriptionCacheService =
      SubscriptionCacheService();
  bool _hasPaidSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionBadgeState();
  }

  Future<void> _loadSubscriptionBadgeState() async {
    final hasPaidSubscription = await _subscriptionCacheService
        .hasPaidSubscription();
    if (!mounted) return;

    setState(() {
      _hasPaidSubscription = hasPaidSubscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sessionController,
      builder: (context, _) {
        final user = _sessionController.user;
        return MyScaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Transform.translate(
                      offset: Offset(
                        -16.w,
                        0,
                      ), // Pulls the BackButton left by screen padding amount
                      child: BackButton(color: context.colors.textPrimary),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Profile",
                          style: context.typography.title.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: context.colors.tertiary,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Color(0xFF475569),
                                backgroundImage:
                                    (user?.avatarUrl != null &&
                                        user!.avatarUrl!.isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        user.avatarUrl!,
                                      )
                                    : null,
                                child:
                                    (user?.avatarUrl == null ||
                                        user!.avatarUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 24.r,
                                      )
                                    : null,
                              ),
                            ),
                            if (_hasPaidSubscription)
                              Positioned(
                                top: 0,
                                right: -5.w,
                                width: 28.w,
                                height: 28.h,
                                child: Assets.icons.premium.svg(),
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          user?.username ?? "",
                          style: context.typography.title.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: "sfpro",
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Settings",
                            style: context.typography.title.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                              fontFamily: "sfpro",
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ProfileMenuTile(
                          icon: Assets.icons.pen2.svg(
                            color: context.colors.tertiary,
                          ),
                          text: "Edit Profile",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.editProfile,
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        ProfileMenuTile(
                          icon: Assets.icons.lockIcon.svg(
                            color: context.colors.tertiary,
                          ),
                          text: "Change Password",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.changePassword,
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        ProfileMenuTile(
                          icon: Assets.icons.iconsProductSubscriptions.svg(
                            color: context.colors.tertiary,
                          ),
                          text: "Subscription Plan",
                          onTap: () {
                            if (!context
                                .read<ConnectivityProvider>()
                                .isConnected) {
                              MyDialogBox.show(
                                context,
                                child: const NoInternetDialog(),
                              );
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              RoutesName.activeSubscription,
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        ProfileMenuTile(
                          icon: Icon(
                            Icons.description_outlined,
                            color: context.colors.tertiary,
                          ),
                          text: "Terms & Conditions",
                          onTap: () => openLegalUrl(
                            context,
                            ExternalLinks.kenaTermsAndConditions,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ProfileMenuTile(
                          icon: Icon(
                            Icons.privacy_tip_outlined,
                            color: context.colors.tertiary,
                          ),
                          text: "Privacy Policy",
                          onTap: () => openLegalUrl(
                            context,
                            ExternalLinks.kenaPrivacyPolicy,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ProfileMenuTile(
                          sufix: SizedBox.shrink(),
                          icon: Assets.icons.trashBin.svg(),
                          text: "Delete Account",
                          textColor: Colors.red,
                          onTap: () {
                            MyDialogBox.show(
                              context,
                              child: DeleteAccountDialog(
                                authService: _authService,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const BannerAdWidget(),
                SizedBox(height: 10.h),
                MyButton(
                  label: "Logout",
                  onPressed: () {
                    MyDialogBox.show(
                      context,
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // allow height to wrap content
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Logout",
                              style: context.typography.title.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                                fontFamily: "Raleway",
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              "Are you sure you want to logout?",
                              textAlign: TextAlign.center,
                              style: context.typography.title.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textSecondary,
                                fontFamily: "Raleway",
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: context.colors.textSecondary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: context.typography.title
                                              .copyWith(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    context.colors.textPrimary,
                                                fontFamily: "Raleway",
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // child: MyButton(
                                  //   label: "Cancel",
                                  //   fontWeight: FontWeight.w600,
                                  //   textColor: context.colors.textPrimary,
                                  //   backgroundColor: context.colors.background
                                  //       .withOpacity(0.8),
                                  //   borderColor: context.colors.textSecondary
                                  //       .withOpacity(0.1),
                                  //   onPressed: () => Navigator.pop(context),
                                  // ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: MyButton(
                                    fontWeight: FontWeight.w600,
                                    label: "Log Out",
                                    onPressed: () =>
                                        AuthService.logout(context),
                                    backgroundColor: context.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

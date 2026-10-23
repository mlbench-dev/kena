import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/community/user_community.dart';
import 'package:kena_emotional_journey/model/user/users_model.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/community/my_community_screen.dart'
    as comm_screen;
import 'package:kena_emotional_journey/view/community/widgets/user_profile_shimmer.dart';
import 'package:provider/provider.dart';

class InviteMembersScreen extends StatefulWidget {
  final String communityId;
  const InviteMembersScreen({super.key, required this.communityId});

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final TextEditingController _inviteController = TextEditingController();
  final UserHomeService _userHomeService = UserHomeService();
  UserModel get _userModel => SessionController().user ?? UserModel();
  bool isButtonEnabled = false;
  final _formKey = GlobalKey<FormState>();
  String selectedType = "Username";

  UserCommunity? communityModel;
  bool isLoading = true;
  bool _isSendingInvite = false;

  bool get _isEmailType => selectedType == "Email";

  @override
  void initState() {
    super.initState();
    fetchCommunity();
    _inviteController.addListener(() {
      setState(() {
        // Enable button only if text is not empty
        isButtonEnabled = _inviteController.text.trim().isNotEmpty;
      });
    });
  }

  /// All usernames / emails typed in the field (comma or space separated),
  /// trimmed and de-duplicated.
  List<String> get _recipients {
    final seen = <String>{};
    return _inviteController.text
        .split(RegExp(r'[,;\s]+'))
        .map((e) => e.trim().replaceFirst(RegExp(r'^@'), ''))
        .where((e) => e.isNotEmpty && seen.add(e.toLowerCase()))
        .toList();
  }

  Future<void> _sendInvites() async {
    final recipients = _recipients;
    if (recipients.isEmpty) return;

    setState(() => _isSendingInvite = true);
    try {
      final result = _isEmailType
          ? await _userHomeService.inviteEmails(
              context: context,
              emails: recipients,
              communityId: widget.communityId,
            )
          : await _userHomeService.inviteUsernames(
              context: context,
              usernames: recipients,
              communityId: widget.communityId,
            );

      if (!mounted || result == null) return;

      // Leave only the failed entries in the field so the user can fix them.
      final failed = (result.failed ?? [])
          .map((f) => (f.email ?? f.username ?? '').toLowerCase())
          .toSet();
      _inviteController.text = recipients
          .where((r) => failed.contains(r.toLowerCase()))
          .join(', ');
    } finally {
      if (mounted) {
        setState(() => _isSendingInvite = false);
      }
    }
  }

  /// Name used in the invite preview.
  String get _previewName {
    final names = _recipients;
    return names.length == 1 ? names.first : (names.isEmpty ? '' : 'there');
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> fetchCommunity() async {
    final result = await _userHomeService.getUserCommunity(
      communityId: widget.communityId,
      context: context,
    );
    if (mounted) {
      setState(() {
        communityModel = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityData = communityModel?.data?.isNotEmpty == true
        ? communityModel!.data!.first
        : null;
    final members = communityData?.members ?? [];
    final actions = context.watch<NavigationActionsController>();
    return MyScaffold(
      endDrawer: MyDrawer(
        items: [
          DrawerMenuItem(
            icon: Assets.icons.homeOutline.svg(),
            label: 'Home',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.homeScreen);
            },
          ),
          DrawerMenuItem(
            icon: Assets.icons.aspire.svg(),
            label: 'Aspire',
            isLoading: actions.aspireLoading,
            isDisabled: actions.isAnyLoading && !actions.aspireLoading,
            isAsync: true,
            onTap: () => actions.onAspireTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.dailyPuls.svg(),
            label: 'Daily Pulse',
            isLoading: actions.forecastLoading,
            isDisabled: actions.isAnyLoading && !actions.forecastLoading,
            isAsync: true,
            onTap: () => actions.onForecastTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.activity.svg(),
            label: 'Activities',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onActivitiesTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.circle.svg(),
            label: 'Circle',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onCommunityTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.bellIcon.svg(),
            label: 'Notifications',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.notificationScreen);
            },
          ),
          DrawerMenuItem(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: 'Logout',
            isDisabled: actions.isAnyLoading,
            onTap: () => AuthService.logout(context),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          "Invite Members",
          style: context.typography.headline.copyWith(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
            fontFamily: "sfpro",
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Builder(
              builder: (scaffoldContext) => GestureDetector(
                onTap: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.menu,
                    color: context.colors.textPrimary,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 25.h),
                // Text(
                //   "Build your support circle by inviting friends and family to share your emotional journey.",
                //   style: context.typography.body.copyWith(
                //     fontSize: 15.sp,
                //     color: context.colors.textSecondary,
                //     fontWeight: FontWeight.w400,
                //     fontFamily: "Raleway",
                //   ),
                // ),
                // SizedBox(height: 15.h),
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.all(16.w),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFE4F1E9),
                //     border: Border.all(color: const Color(0xFF20573B)),
                //     borderRadius: BorderRadius.circular(12.r),
                //   ),
                //   child: Row(
                //     crossAxisAlignment:
                //         CrossAxisAlignment.start, // Align icon to top of text
                //     children: [
                //       Icon(Icons.email_outlined, color: context.colors.primary),
                //       SizedBox(width: 10.w),
                //       // 🔥 WRAP THIS COLUMN IN EXPANDED
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment:
                //               CrossAxisAlignment.start, // Align text to left
                //           children: [
                //             Text(
                //               "Daily Forecast Emails",
                //               style: context.typography.headline.copyWith(
                //                 fontSize: 15.sp,
                //                 fontWeight: FontWeight.w600,
                //                 color: context.colors.primary,
                //                 fontFamily: "sfpro",
                //               ),
                //             ),
                //             SizedBox(
                //               height: 8.h,
                //             ), // Add a little gap between title and body
                //             Text(
                //               "Your invited members will receive ONLY a daily email when you share a forecast. No spam, just supportive updates.",
                //               textAlign: TextAlign.start,
                //               maxLines: 3,
                //               overflow: TextOverflow.ellipsis,
                //               style: context.typography.body.copyWith(
                //                 fontSize: 12.sp,
                //                 color: context.colors.textSecondary,
                //                 fontWeight: FontWeight.w400,
                //                 fontFamily: "Raleway",
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 35.h),
                AnimatedToggle(
                  onChanged: (value) {
                    if (value == selectedType) return;
                    setState(() => selectedType = value);
                    // Usernames and emails go to different endpoints.
                    _inviteController.clear();
                  },
                ),
                SizedBox(height: 15.h),
                Text(
                  selectedType == "Username" ? "Usernames" : "Emails",
                  style: context.typography.body.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5.h),
                MyFormTextField(
                  textColor: context.colors.textPrimary,
                  controller: _inviteController,
                  hint: selectedType == "Username"
                      ? "e.g. ali, sara, john"
                      : "e.g. ali@mail.com, sara@mail.com",
                  fillColor: Color(0xFFf5f5f7),
                  readOnly: _isSendingInvite,
                  keyboardType: _isEmailType
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final entries = _recipients;
                    if (entries.isEmpty) {
                      return '$selectedType is required.';
                    }
                    if (_isEmailType) {
                      final invalid = entries
                          .where((e) => !e.emailValidator())
                          .toList();
                      if (invalid.isNotEmpty) {
                        return 'Invalid email: ${invalid.join(', ')}';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5.h),
                Text(
                  "Separate multiple entries with commas",
                  style: context.typography.body.copyWith(
                    color: context.colors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFfff9e6),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📧 Invite Message Preview",
                        style: context.typography.headline.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B7A3F),
                          fontFamily: "sfpro",
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "Hi $_previewName, I've been using Kena to stay on top of my wellness and reflect on my days and would love for you to be part of my support circle. You'll be able to see my daily assessments and leave encouraging comments. No pressure at all! Thank you ❤️ $_previewName",
                        style: context.typography.headline.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8B7A3F),
                          fontFamily: "Raleway",
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                MyButton(
                  label: _recipients.length > 1
                      ? "Send ${_recipients.length} Invites"
                      : "Send Invite",
                  isLoading: _isSendingInvite,
                  onPressed: isButtonEnabled && !_isSendingInvite
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            await _sendInvites();
                          }
                        }
                      : null,
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Circle",
                      style: context.typography.headline.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                        fontFamily: "sfpro",
                      ),
                    ),
                    Text(
                      "${(communityData?.memberCount ?? 0)}/${communityData?.maxMembers ?? 0} members",
                      style: context.typography.headline.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: (isLoading && members.isEmpty)
                      ? Center(child: UserProfileShimmerLoading())
                      : members.isNotEmpty
                      ? Center(
                          child: Wrap(
                            spacing: 30.w,
                            children: members.map((member) {
                              final user = member.user;

                              return comm_screen.UserProfiles(
                                name:
                                    user?.aliasName ?? user?.username ?? "User",
                                image: user?.avatarUrl ?? "",
                              );
                            }).toList(),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                            horizontal: 10.w,
                          ),
                          child: Text(
                            "No members yet. Start inviting people to build your support circle!",
                            textAlign: TextAlign.center,
                            style: context.typography.headline.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 15.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF5EF),
                    border: Border.all(color: context.colors.textSecondary),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🔒 Privacy & Sharing",
                        style: context.typography.headline.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          fontFamily: "sfpro",
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "• Members can only see shared forecasts and reflections",
                        style: context.typography.headline.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                          fontFamily: "Raleway",
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "• Everything else remains private",
                        style: context.typography.headline.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                          fontFamily: "Raleway",
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "• You can opt-out or remove members anytime",
                        style: context.typography.headline.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedToggle extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AnimatedToggle({super.key, required this.onChanged});

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  String selectedType = "Username";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final gap = 10.w;

          final itemWidth = (totalWidth - gap) / 2;

          return Stack(
            children: [
              /// 🔥 Sliding Indicator (with gap)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: selectedType == "Username" ? 0 : itemWidth + gap,
                top: 0,
                child: Container(
                  width: itemWidth,
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              /// 🔘 Buttons
              Row(
                children: [
                  /// Username
                  SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = "Username";
                        });
                        widget.onChanged(selectedType);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedType == "Username"
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: selectedType == "Username"
                                  ? context.colors.background
                                  : context.colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Username",
                              style: TextStyle(
                                color: selectedType == "Username"
                                    ? context.colors.background
                                    : context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: gap), // 👈 spacing
                  /// Email
                  SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = "Email";
                        });
                        widget.onChanged(selectedType);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedType == "Email"
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: selectedType == "Email"
                                  ? context.colors.background
                                  : context.colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Email",
                              style: TextStyle(
                                color: selectedType == "Email"
                                    ? context.colors.background
                                    : context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

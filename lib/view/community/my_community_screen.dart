import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/community/community_detail_model.dart';
import 'package:kena_emotional_journey/model/community/invitations_model.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/community/empty_community.dart';
import 'package:kena_emotional_journey/view/community/widgets/button_shimmer_loading.dart';
import 'package:kena_emotional_journey/view/community/widgets/explore_feeds_shimmer.dart';
import 'package:kena_emotional_journey/view/community/widgets/invitation_shimmer.dart';
import 'package:kena_emotional_journey/view/community/widgets/user_profile_shimmer.dart';

class MyCommunityScreen extends StatefulWidget {
  // final String communityId;
  // final String communityName;
  const MyCommunityScreen({
    super.key,
    // required this.communityId,
    // required this.communityName,
  });

  @override
  State<MyCommunityScreen> createState() => _MyCommunityScreenState();
}

class _MyCommunityScreenState extends State<MyCommunityScreen> {
  CommunityDetailModel? communityDetailModel;
  InvitationsModel? invitationsModel;
  List<Invitation> invitationsList = [];
  final SessionController _sessionController = SessionController();
  bool isCommunityLoading = true;
  bool isInvitationsLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCommunityDetails();
    fetchInvitations();
  }

  Future<void> fetchCommunityDetails() async {
    final communityId = _sessionController.communityId;
    if (communityId == null) {
      if (mounted) {
        setState(() {
          isCommunityLoading = false;
        });
      }
      return;
    }

    final result = await UserHomeService().getUserCommunityDetails(
      communityId: communityId,
      context: context,
    );

    if (mounted) {
      setState(() {
        communityDetailModel = result;
        isCommunityLoading = false;
      });
    }
  }

  Future<void> fetchInvitations() async {
    try {
      setState(() {
        isInvitationsLoading = true;
      });

      final result = await UserHomeService().getInvitations(context: context);

      if (!mounted) return;

      setState(() {
        invitationsModel = result;

        // ✅ flatten and filter — only show invites that are still pending
        invitationsList =
            result?.data
                ?.expand((list) => list)
                .where((inv) => inv.status == 'pending')
                .toList() ??
            [];

        isInvitationsLoading = false;
      });
    } catch (e) {
      setState(() {
        isInvitationsLoading = false;
      });
      debugPrint("Fetch invitations error: $e");
    }
  }

  Future<void> _removeMember(String memberId, String memberName) async {
    // Show confirmation dialog
    final confirmed = await MyDialogBox.show<bool>(
      context,
      child: RemoveMemberDialog(
        onLeave: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
        // You can customize the text inside LeaveCommentDialog if needed
      ),
    );

    if (confirmed != true || !mounted) return;

    // Call API to remove member
    final success = await UserHomeService().removeCommunityMember(
      memberId: memberId,
      context: context,
    );

    if (success && mounted) {
      context.flushBarSuccessMessage(
        message: '$memberName removed from community',
      );
      fetchCommunityDetails(); // Refresh the list
    }
  }

  Future<void> _acceptInvite(String inviteId) async {
    final success = await UserHomeService().acceptInvite(
      inviteId: inviteId,
      context: context,
    );
    if (success && mounted) {
      context.flushBarSuccessMessage(message: 'Invitation accepted!');
      fetchInvitations();
      fetchCommunityDetails();
    }
  }

  Future<void> _declineInvite(String inviteId) async {
    final success = await UserHomeService().declineInvite(
      inviteId: inviteId,
      context: context,
    );
    if (success && mounted) {
      context.flushBarSuccessMessage(message: 'Invitation declined.');
      fetchInvitations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailData = communityDetailModel?.data?.isNotEmpty == true
        ? communityDetailModel!.data!.first
        : null;

    final communityName =
        detailData?.community?.name ?? detailData?.community?.name;
    final members = detailData?.members ?? [];
    final memberCount = detailData?.memberCount ?? 0;
    final maxMembers = detailData?.maxMembers ?? 0;
    final pendingInvites = detailData?.pendingInvites ?? [];
    return MyScaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(color: context.colors.textPrimary),
                  Expanded(
                    child: Center(
                      child: Text(
                        "My Circle",
                        style: context.typography.headline.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: "sfpro",
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      MyDialogBox.show(
                        context,
                        child: CreateandUpdateCommunityBottomSheet(
                          communityId: _sessionController.communityId,
                          communityName: detailData?.community?.name,
                          communityDescription:
                              detailData?.community?.description,
                          onCommunityUpdated: (name, description) {
                            fetchCommunityDetails();
                          },
                        ),
                      );
                    },
                    child: Assets.icons.editCircle.svg(),
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              Row(
                children: [
                  SizedBox(
                    width: 260.w,
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      detailData?.community?.name ?? "",
                      style: context.typography.headline.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "sfpro",
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "$memberCount/$maxMembers",
                    style: context.typography.headline.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: (isCommunityLoading && members.isEmpty)
                    ? Center(child: UserProfileShimmerLoading())
                    : members.isNotEmpty
                    ? Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20.w,
                        children: members.map((member) {
                          final user = member.user;

                          return UserProfiles(
                            name: user?.aliasName ?? user?.username ?? "User",
                            image: user?.avatarUrl ?? "",
                            showRemoveIcon: true,
                            onRemove: () {
                              _removeMember(
                                member.id ?? '',
                                user?.aliasName ?? user?.username ?? 'User',
                              );
                            },
                          );
                        }).toList(),
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
              isInvitationsLoading
                  ? ButtonShimmerLoading()
                  : MyButton(
                      icon: Icon(Icons.person_add),
                      label: "Invite Friends",
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          RoutesName.inviteMembers,
                          arguments: _sessionController.communityId,
                        );

                        if (result == true) {
                          fetchCommunityDetails();
                        }
                      },
                    ),
              SizedBox(height: 15.h),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.feedScreen,
                    arguments: {
                      'communityId': _sessionController.communityId,
                      'communityName': detailData?.community?.name,
                    },
                  );
                },
                child: isInvitationsLoading
                    ? ExploreFeedsShimmer()
                    : Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFd4e9de),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Feed",
                                  style: context.typography.headline.copyWith(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                    fontFamily: "sfpro",
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                SizedBox(
                                  width: 230.w,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    "See how your circle & friends are feeling today",
                                    style: context.typography.headline.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: context.colors.textPrimary,
                                      fontFamily: "Raleway",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            CircleAvatar(
                              backgroundColor: Color(0xFFa0aeab),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 15.h),
              isInvitationsLoading
                  ? InvitationShimmer()
                  : invitationsList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pending Invitations",
                          style: context.typography.headline.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: "sfpro",
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...invitationsList.map((invite) {
                          final inviteId = invite.id ?? '';
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: InviteRequestCard(
                              imageUrl: invite.inviter?.avatarUrl ?? '',
                              name:
                                  invite.inviter?.aliasName ??
                                  invite.inviter?.username ??
                                  'Someone',
                              communityName:
                                  invite.community?.name ??
                                  detailData?.community?.name ??
                                  '',
                              onAccept: inviteId.isNotEmpty
                                  ? () => _acceptInvite(inviteId)
                                  : null,
                              onDecline: inviteId.isNotEmpty
                                  ? () => _declineInvite(inviteId)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    )
                  : const SizedBox.shrink(),
              // SizedBox(height: 15.h),
              // Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.all(16.w),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFE4F1E9),
              //     border: Border.all(color: const Color(0xFF20573B)),
              //     borderRadius: BorderRadius.circular(12.r),
              //   ),
              //   child: Column(
              //     // Removed Expanded from here
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Icon(
              //             Icons.lock_outline_rounded,
              //             color: context.colors.primary,
              //           ),
              //           SizedBox(width: 10.w),
              //           Text(
              //             "Privacy Settings",
              //             style: context.typography.headline.copyWith(
              //               fontSize: 15.sp,
              //               fontWeight: FontWeight.w600,
              //               color: context.colors.primary,
              //               fontFamily: "sfpro",
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 15.h),
              //       _buildPrivacyRow(
              //         context,
              //         icon: Icons.visibility_outlined,
              //         title: "Who can see my forecast?",
              //         subtitle: "Only people you invite to your support circle",
              //       ),
              //       SizedBox(height: 15.h),
              //       _buildPrivacyRow(
              //         context,
              //         icon: Icons.people_outline,
              //         title: "What do they see?",
              //         subtitle:
              //             "Only your Forecasts and End-of-Day Reflections",
              //       ),
              //       SizedBox(height: 15.h),
              //       _buildPrivacyRow(
              //         context,
              //         icon: Icons.shield_outlined,
              //         title: "Privacy",
              //         subtitle:
              //             "Everything else (Aspire, Activities, personal data) is hidden",
              //       ),
              //     ],
              //   ),
              // ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class InviteRequestCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String communityName;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InviteRequestCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.communityName,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<InviteRequestCard> createState() => _InviteRequestCardState();
}

class _InviteRequestCardState extends State<InviteRequestCard> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFd4e9de),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundImage: widget.imageUrl.isNotEmpty
                ? NetworkImage(widget.imageUrl)
                : null,
            child: widget.imageUrl.isEmpty
                ? Icon(Icons.person, size: 18.sp)
                : null,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  widget.communityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          // Accept button
          GestureDetector(
            onTap: (_isAccepting || _isDeclining || widget.onAccept == null)
                ? null
                : () async {
                    setState(() => _isAccepting = true);
                    await Future.microtask(() => widget.onAccept!());
                    if (mounted) setState(() => _isAccepting = false);
                  },
            child: Container(
              width: 70.w,
              height: 25.h,
              decoration: BoxDecoration(
                color: widget.onAccept == null || _isAccepting
                    ? context.colors.primary.withValues(alpha: 0.5)
                    : context.colors.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: _isAccepting
                    ? SizedBox(
                        width: 12.w,
                        height: 12.h,
                        child: LoadingWidget(color: context.colors.background),
                      )
                    : Text(
                        "Accept",
                        style: context.typography.body.copyWith(
                          fontSize: 10.sp,
                          color: context.colors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Decline button
          GestureDetector(
            onTap: (_isAccepting || _isDeclining || widget.onDecline == null)
                ? null
                : () async {
                    setState(() => _isDeclining = true);
                    await Future.microtask(() => widget.onDecline!());
                    if (mounted) setState(() => _isDeclining = false);
                  },
            child: Container(
              width: 70.w,
              height: 25.h,
              decoration: BoxDecoration(
                color: widget.onDecline == null || _isDeclining
                    ? const Color(0xFFF2DBD9).withValues(alpha: 0.5)
                    : const Color(0xFFF2DBD9),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: _isDeclining
                    ? SizedBox(
                        width: 12.w,
                        height: 12.h,
                        child: LoadingWidget(color: context.colors.error),
                      )
                    : Text(
                        "Decline",
                        style: context.typography.body.copyWith(
                          fontSize: 10.sp,
                          color: context.colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfiles extends StatelessWidget {
  final String name;
  final String? image;
  final bool showRemoveIcon;
  final VoidCallback? onRemove;

  const UserProfiles({
    super.key,
    required this.name,
    this.image,
    this.showRemoveIcon = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF475569),
              radius: 24.r,
              backgroundImage: (image != null && image!.isNotEmpty)
                  ? NetworkImage(image!)
                  : null,
              child: (image == null || image!.isEmpty)
                  ? Icon(Icons.person, size: 20.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(height: 10.h),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.headline.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),

        // 🔥 Minus Icon (Top Right) — only shown when allowed
        if (showRemoveIcon)
          Positioned(
            top: -4.h,
            right: -4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                height: 20.h,
                width: 20.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red, width: 1.5),
                ),
                child: Center(
                  child: Icon(Icons.remove, size: 14.sp, color: Colors.red),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Widget _buildPrivacyRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // Align icon with top of text
    children: [
      Icon(icon, color: context.colors.primary),
      SizedBox(width: 10.w),
      // 🔥 THIS Expanded is what stops the overflow
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.typography.headline.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.headline.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class RemoveMemberDialog extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onCancel;
  const RemoveMemberDialog({
    super.key,
    required this.onLeave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // allow height to wrap content
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Remove Member",
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Are you sure you want to remove this member from the community?",
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
                child: MyButton(
                  label: "Cancel",
                  fontWeight: FontWeight.w600,
                  textColor: context.colors.textPrimary,
                  backgroundColor: context.colors.background.withValues(
                    alpha: 0.8,
                  ),
                  borderColor: context.colors.textSecondary.withValues(
                    alpha: 0.1,
                  ),
                  onPressed: onCancel,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: MyButton(
                  fontWeight: FontWeight.w600,
                  label: "Yes Remove",
                  onPressed: onLeave,
                  backgroundColor: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

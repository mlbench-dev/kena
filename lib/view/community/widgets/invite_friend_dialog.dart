import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';

import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendsDialog extends StatefulWidget {
  final String communityId;
  const InviteFriendsDialog({super.key, required this.communityId});

  @override
  State<InviteFriendsDialog> createState() => _InviteFriendsDialogState();
}

class _InviteFriendsDialogState extends State<InviteFriendsDialog> {
  final TextEditingController _emailController = TextEditingController();
  final UserHomeService _userHomeService = UserHomeService();

  String? _inviteLink;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInviteLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Fetch Invite Link API
  Future<void> _fetchInviteLink() async {
    setState(() => _isLoading = true);

    final res = await _userHomeService.getInviteLink(context: context);

    if (res != null && res.data != null && res.data!.isNotEmpty) {
      _inviteLink = res.data!.first.url;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Share Link
  void _shareLink() {
    if (_inviteLink == null) return;

    Share.share(
      "Join me on this app 🚀\n$_inviteLink",
      subject: "Invite to join app",
    );
  }

  /// Copy Link Function
  void _copyLink() {
    if (_inviteLink == null) return;

    Clipboard.setData(ClipboardData(text: _inviteLink!));

    /// ✅ Success Flash Message
    if (context.mounted) {
      context.flushBarSuccessMessage(message: "Link copied successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      height: 370.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Center(
              child: Text(
                "Invite Friends",
                style: typography.title.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            /// Subtitle
            Center(
              child: Text(
                "Share your private link and grow together.",
                textAlign: TextAlign.center,
                style: typography.body.copyWith(
                  color: colors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            /// Invite Link Label
            Text(
              "Your Private Invite Link",
              style: typography.body.copyWith(
                color: colors.textPrimary,
                fontSize: 15.sp,
              ),
            ),

            SizedBox(height: 10.h),

            /// Invite Link UI
            _isLoading
                ? const Center(child: LoadingWidget())
                : _LinkRow(
                    value: _inviteLink ?? "No link available",
                    icon: Icons.copy,
                    onIconTap: _copyLink,
                  ),

            SizedBox(height: 10.h),

            /// Email Invite Label
            Text(
              "Invite via Email",
              style: typography.body.copyWith(
                color: colors.textPrimary,
                fontSize: 15.sp,
              ),
            ),

            SizedBox(height: 10.h),

            /// Email Input
            _LinkRow(
              controller: _emailController,
              hint: "Enter email address",
              icon: Icons.send,
              onIconTap: () {
                if (_emailController.text.isNotEmpty) {
                  _userHomeService.inviteEmail(
                    context: context,
                    email: _emailController.text,
                    communityId: widget.communityId,
                  );

                  if (mounted) {
                    _emailController.clear();
                    context.flushBarSuccessMessage(message: "Invitation sent");
                  }
                }
              },
            ),

            SizedBox(height: 15.h),

            /// Share Button
            GestureDetector(
              onTap: _shareLink,
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.share.svg(width: 22, height: 22),
                    SizedBox(width: 15.w),
                    Text(
                      "Share Via Other Apps",
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable row with a text field + action icon button.
class _LinkRow extends StatelessWidget {
  final TextEditingController? controller;
  final String? value;
  final String? hint;
  final IconData icon;
  final VoidCallback onIconTap;

  const _LinkRow({
    this.controller,
    this.value,
    this.hint,
    required this.icon,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            controller: controller,
            hint: value ?? hint ?? "",
            readOnly: value != null,
            fillColor: Colors.transparent,
            borderColor: context.colors.textSecondary.withOpacity(0.3),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: onIconTap,
          child: Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: context.colors.background, size: 20.sp),
          ),
        ),
      ],
    );
  }
}

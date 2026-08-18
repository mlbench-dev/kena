import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';

class EmptyCommunityScreen extends StatelessWidget {
  const EmptyCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text(
          "Circle",
          style: context.typography.body.copyWith(
            fontSize: 20.sp,
            fontFamily: 'sfpro',
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        leading: BackButton(color: context.colors.textPrimary),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: context.colors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Assets.icons.lockIcon.svg(),
                        SizedBox(width: 8.h),
                        Text(
                          "Privacy & Sharing",
                          style: context.typography.body.copyWith(
                            fontSize: 16.sp,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w600,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Who can see?",
                      style: context.typography.body.copyWith(
                        fontSize: 13.sp,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Only those you invite on a given day to see your days reflections.",
                      style: context.typography.body.copyWith(
                        fontSize: 12.sp,
                        fontFamily: 'raleway',
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "What they see?",
                      style: context.typography.body.copyWith(
                        fontSize: 13.sp,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Daily Sharing: ",
                            style: context.typography.body.copyWith(
                              fontSize: 12.sp,
                              fontFamily: 'raleway',
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                "The reflections for the day you invite them i.e. forecast emotions, plan and end of day reflections. If they are not invited the next day they will not see your reflections.",
                            style: context.typography.body.copyWith(
                              fontSize: 12.sp,
                              fontFamily: 'raleway',
                              fontWeight: FontWeight.w400,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Weekly sharing:  ",
                            style: context.typography.body.copyWith(
                              fontSize: 12.sp,
                              fontFamily: 'raleway',
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                "The weekly prediction insights, forecast vs actual emotions for the week, and top 5 activities.",
                            style: context.typography.body.copyWith(
                              fontSize: 12.sp,
                              fontFamily: 'raleway',
                              fontWeight: FontWeight.w400,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "What they see?",
                      style: context.typography.body.copyWith(
                        fontSize: 13.sp,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletItem(
                          context,
                          "Invite using username or email address. Once they accept your invite they reflect in your circle and you can share your forecasts with them.",
                        ),
                        SizedBox(
                          height: 12.h,
                        ), // Adjust spacing between bullets as needed
                        _buildBulletItem(
                          context,
                          "You can opt-out of circles or remove members from your circle anytime.",
                        ),
                        SizedBox(height: 12.h),
                        _buildBulletItem(
                          context,
                          "You choose which forecasts to share and with who. They are not automatically visible to your circle.",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.textSecondary.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    Assets.icons.personsContainer.svg(),
                    SizedBox(height: 12.h),
                    Text(
                      "No Circle yet",
                      style: context.typography.body.copyWith(
                        fontSize: 17.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      textAlign: TextAlign.center,
                      "Your Circle is private. Invite friends to start building a supportive space.",
                      style: context.typography.body.copyWith(
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    MyButton(
                      label: "Create Circle",
                      onPressed: () {
                        MyDialogBox.show(
                          context,
                          child: CreateandUpdateCommunityBottomSheet(
                            onCommunityCreated: () {
                              // Replace the empty screen with the my community screen
                              Navigator.pushReplacementNamed(
                                context,
                                RoutesName.myCommunity,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildBulletItem(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // The Bullet Point
      Text(
        "• ",
        style: context.typography.body.copyWith(
          fontSize: 12.sp,
          fontFamily: 'raleway',
          fontWeight: FontWeight.w400,
          color: context.colors.textSecondary,
        ),
      ),
      // The Content
      Expanded(
        child: Text(
          text,
          style: context.typography.body.copyWith(
            fontSize: 12.sp,
            fontFamily: 'raleway',
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
            height: 1.4, // Improves readability for wrapped lines
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Create Community Bottom Sheet
// ---------------------------------------------------------------------------

class CreateandUpdateCommunityBottomSheet extends StatefulWidget {
  // FIX: Added callback so parent can refresh after creation
  final VoidCallback? onCommunityCreated;

  /// Called after a successful update with the new name and description.
  final void Function(String name, String description)? onCommunityUpdated;
  final String? communityId;
  final String? communityName;
  final String? communityDescription;

  const CreateandUpdateCommunityBottomSheet({
    super.key,
    this.onCommunityCreated,
    this.onCommunityUpdated,
    this.communityId,
    this.communityName,
    this.communityDescription,
  });

  bool get isEditMode => communityId != null;

  @override
  State<CreateandUpdateCommunityBottomSheet> createState() =>
      _CreateandUpdateCommunityBottomSheetState();
}

class _CreateandUpdateCommunityBottomSheetState
    extends State<CreateandUpdateCommunityBottomSheet> {
  final UserHomeService _userHomeService = UserHomeService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing an existing community
    if (widget.isEditMode) {
      _nameController.text = widget.communityName ?? '';
      _descController.text = widget.communityDescription ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // FIX: Moved createCommunity out of build() into a proper state method
  Future<void> _createCommunity() async {
    if (_nameController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      context.flushBarErrorMessage(message: "Please fill all the fields");
      return;
    }

    setState(() => _isCreating = true);

    final communityId = await _userHomeService.createCommunity(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      context: context,
    );

    if (!mounted) return;

    setState(() => _isCreating = false);

    if (communityId != null) {
      Navigator.pop(context);

      // Persist the community ID so subsequent visits skip the empty screen
      await SessionController().saveCommunityId(communityId: communityId);

      // Notify parent to refresh community data
      widget.onCommunityCreated?.call();

      MyBottomSheet.show(
        isDismissible: true,
        context,
        child: CommunityIsReady(communityId: communityId),
      );
    }
  }

  /// Updates an existing community and notifies the parent with new values.
  Future<void> _updateCommunity() async {
    if (_nameController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      context.flushBarErrorMessage(message: "Please fill all the fields");
      return;
    }

    setState(() => _isCreating = true);

    final success = await _userHomeService.updateCommunity(
      communityId: widget.communityId!,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      context: context,
    );

    if (!mounted) return;

    setState(() => _isCreating = false);

    if (success) {
      Navigator.pop(context);

      // Notify parent with updated values so it can refresh UI immediately
      widget.onCommunityUpdated?.call(
        _nameController.text.trim(),
        _descController.text.trim(),
      );

      context.flushBarSuccessMessage(message: "Community updated successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    widget.isEditMode ? "Update Your Circle" : "Create Circle",
                    style: context.typography.body.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                  // SizedBox(height: 10.h),
                  // Text(
                  //   widget.isEditMode
                  //       ? "Update your community name and description."
                  //       : "Build a private emotional space for you and your trusted friends.",
                  //   textAlign: TextAlign.center,
                  //   style: context.typography.body.copyWith(
                  //     color: context.colors.textSecondary,
                  //     fontWeight: FontWeight.w400,
                  //     fontSize: 16.sp,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Community Name field
            Text(
              "Name",
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            MyTextField(
              maxLength: 30,
              controller: _nameController,
              hint: "Enter your Circle name",
              fillColor: Colors.transparent,
              borderColor: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
            // SizedBox(height: 10.h),
            // Text(
            //   "Choose a meaningful name for your group.",
            //   style: context.typography.body.copyWith(
            //     color: context.colors.textSecondary,
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            SizedBox(height: 20.h),

            // Description field
            Text(
              "Description",
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            MyTextField(
              controller: _descController,
              maxLines: 6,
              hint: "Write a short description about your circle purpose.",
              fillColor: Colors.transparent,
              borderColor: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
            SizedBox(height: 20.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    fontWeight: FontWeight.w500,
                    label: "Cancel",
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.transparent,
                    borderWidth: 1,
                    borderColor: context.colors.primary,
                    textColor: context.colors.primary,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: MyButton(
                    fontWeight: FontWeight.w500,
                    label:
                        //  _isCreating
                        //     ? (widget.isEditMode ? "Updating..." : "Creating...")
                        //     :
                        (widget.isEditMode ? "Update" : "Create"),
                    onPressed: _isCreating
                        ? null
                        : (widget.isEditMode
                              ? _updateCommunity
                              : _createCommunity),
                    backgroundColor: context.colors.primary,
                    isLoading: _isCreating,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Community Is Ready Bottom Sheet
// ---------------------------------------------------------------------------

class CommunityIsReady extends StatelessWidget {
  final String communityId;
  const CommunityIsReady({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: SizedBox(
        height: 270.h,
        child: Column(
          children: [
            Center(
              child: Assets.images.partyPopper.image(width: 48, height: 67),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Your Community is ready",
                style: context.typography.title.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "Invite friends to start building a supportive space.",
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            MyButton(
              textColor: context.colors.background,
              fontWeight: FontWeight.w500,
              label: "Invite Friends",
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.inviteMembers);
                // MyDialogBox.show(
                //   context,
                //   child: InviteFriendsDialog(communityId: communityId),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}

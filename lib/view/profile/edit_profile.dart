import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_form_text_field.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/extensions/validations_exception.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:kena_emotional_journey/services/user/user_profile_service.dart';
import 'package:kena_emotional_journey/view/profile/widgets/profile_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _userProfileService = UserProfileService();
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _subscriptionCacheService = SubscriptionCacheService();

  bool isLoading = false;
  bool _hasPaidSubscription = false;
  String? _imageUrl;

  // Initial values for change detection
  String _initialEmail = '';
  String _initialUsername = '';
  String _initialAliasName = '';
  String? _initialImageUrl;

  @override
  void initState() {
    setDataFromSession();
    _loadSubscriptionBadgeState();
    // Add listener to rebuild when values change
    _emailController.addListener(_onValueChanged);
    _usernameController.addListener(_onValueChanged);
    _aliasController.addListener(_onValueChanged);
    super.initState();
  }

  Future<void> _loadSubscriptionBadgeState() async {
    final hasPaidSubscription = await _subscriptionCacheService
        .hasPaidSubscription();
    if (!mounted) return;
    setState(() => _hasPaidSubscription = hasPaidSubscription);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onValueChanged);
    _usernameController.removeListener(_onValueChanged);
    _aliasController.removeListener(_onValueChanged);
    _emailController.dispose();
    _usernameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  final _session = SessionController();
  void setDataFromSession() {
    final user = _session.user;
    if (user == null) {
      debugPrint('[EditProfile] user is null — skipping session data');
      return;
    }
    final email = user.email ?? '';
    final userName = user.username ?? '';
    final aliasName = user.aliasName ?? '';
    final image = user.avatarUrl;
    setState(() {
      _emailController.text = email;
      _usernameController.text = userName;
      _aliasController.text = aliasName;
      _imageUrl = image;

      // Store initial values for change detection
      _initialEmail = email;
      _initialUsername = userName;
      _initialAliasName = aliasName;
      _initialImageUrl = image;
      debugPrint('here ${user.avatarUrl}');
    });
  }

  // / Check if any value has changed from initial
  bool get _hasChanges {
    return _emailController.text != _initialEmail ||
        _usernameController.text != _initialUsername ||
        _aliasController.text != _initialAliasName ||
        _imageUrl != _initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: BackButton(color: context.colors.textPrimary),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: context.typography.title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Center(
                    child: //profile image picker (ProfileImagePicker)
                    Stack(
                      children: [
                        ImagePickerAvatar(
                          readOnly: isLoading,
                          initialUrl: _imageUrl,
                          onImageChanged: (url) {
                            _imageUrl = url;
                            debugPrint('url: $url');
                            debugPrint('_imageUrl: $_imageUrl');
                            // Trigger rebuild for change detection
                            if (mounted) setState(() {});
                          },
                        ),
                        if (_hasPaidSubscription)
                          Positioned(
                            right: 115.w,
                            top: 0.w,
                            width: 38.w,
                            height: 38.h,
                            child: Assets.icons.premium.svg(),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Text(
                      _usernameController.text.isNotEmpty
                          ? _usernameController.text
                          : _initialUsername.isNotEmpty
                          ? _initialUsername
                          : "Your Name",
                      style: context.typography.title.copyWith(
                        fontSize: 20.sp,
                        fontFamily: "sfpro",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Email",
                    style: context.typography.title.copyWith(
                      fontSize: 14.sp,
                      fontFamily: "sfpro",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  MyFormTextField(
                    textColor: context.colors.textPrimary,
                    hint: "Enter email",
                    controller: _emailController,
                    readOnly: true,
                    // textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Username",
                    style: context.typography.title.copyWith(
                      fontSize: 14.sp,
                      fontFamily: "sfpro",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  MyFormTextField(
                    textColor: context.colors.textPrimary,
                    hint: "Enter username",
                    controller: _usernameController,
                    readOnly: isLoading,
                    // textCapitalization: TextCapitalization.none,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return "Username is required";
                    //   } else if (!value.nameValidator()) {
                    //     return "Username can only contain letters ";
                    //   }
                    //   return null;
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username is required";
                      } else if (!value.usernameValidator()) {
                        return "Username must contain at least one letter and can only contain letters, numbers, and underscores";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Alias name",
                    style: context.typography.title.copyWith(
                      fontSize: 14.sp,
                      fontFamily: "sfpro",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "This is how you'll appear in the community. ",
                    style: context.typography.title.copyWith(
                      fontSize: 12.sp,
                      fontFamily: "sfpro",
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  MyFormTextField(
                    textColor: context.colors.textPrimary,
                    hint: "Enter alias name",
                    controller: _aliasController,
                    readOnly: isLoading,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return "Username is required";
                    //   } else if (!value.nameValidator()) {
                    //     return "Username must contain at least one letter and can only contain letters, numbers, and underscores";
                    //   }
                    //   return null;
                    // },
                    // textCapitalization: TextCapitalization.none,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return "Name is required";
                    //   } else if (!value.nameValidator()) {
                    //     return "Name must contain at least one letter and can only contain letters, numbers, and underscores";
                    //   }
                    //   return null;
                    // },
                  ),
                  SizedBox(height: 160.h),
                  MyButton(
                    isLoading: isLoading,
                    label: "Update",
                    onPressed: _hasChanges && !isLoading
                        ? () async {
                            if (!formKey.currentState!.validate()) return;
                            if (mounted) {
                              setState(() => isLoading = true);
                            }
                            await _userProfileService.updateUserProfile(
                              context,
                              email: _emailController.text,
                              username: _usernameController.text,
                              aliasName: _aliasController.text,
                              avatarUrl: _imageUrl,
                              onSuccess: () {
                                // Update initial values after successful save
                                _initialEmail = _emailController.text;
                                _initialUsername = _usernameController.text;
                                _initialAliasName = _aliasController.text;
                                _initialImageUrl = _imageUrl;
                                Navigator.pop(context);
                                context.flushBarSuccessMessage(
                                  message: "Profile updated successfully",
                                );
                              },
                            );
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

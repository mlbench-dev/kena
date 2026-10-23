// import 'package:flutter/material.dart';
// import 'package:kena/app/routes/routes_name.dart';
// import 'package:kena/app/utils/service_error_handler.dart';
// import 'package:kena/repository/user_auth_repo.dart';
// import 'package:kena/services/common/auth_service.dart';
// import 'package:kena/services/common/session_manager/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/repository/user_auth_repo.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

class UserProfileService {
  String tag = '[User Profile Service]';
  final _sessionController = SessionController();
  final _userAuthRepo = UserAuthRepository();
  //   static void gotoUserProfile(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userProfile);
  //   }

  //   static void gotoUserEditProfile(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userEditProfile);
  //   }

  //   static void gotoUserFavorites(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userFavorites);
  //   }

  //   static void gotoUserReviews(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userReviews);
  //   }

  //   static void gotoUserLocationProfile(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userlocationProfile);
  //   }

  //   static void gotoNotificationPreferences(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.notificationPerefrences);
  //   }

  ///Update User Profile
  Future<void> updateUserProfile(
    BuildContext context, {
    String? username,
    String? email,
    String? avatarUrl,
    String? aliasName,
    VoidCallback? onSuccess,
  }) async {
    final Map<String, dynamic> data = {
      if (username != null && _sessionController.user!.username != username)
        'username': username,

      if (email != null && _sessionController.user!.email != email)
        'email': email,

      if (aliasName != null && _sessionController.user!.aliasName != aliasName)
        'aliasName': aliasName,

      if (avatarUrl != null && _sessionController.user!.avatarUrl != avatarUrl)
        'avatarUrl': avatarUrl,
    };

    /// Avoid unnecessary API call
    if (data.isEmpty) {
      debugPrint("No changes detected");
      return;
    }

    try {
      await _userAuthRepo.updateProfile(data);

      if (context.mounted) {
        onSuccess?.call();
        await AuthService().fetchProfile(context);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
    }
  }

  //   ///
  //   ///addToFavorites
  //   ///
  //   Future<void> removeFromFavorites(
  //     BuildContext context, {
  //     required String vendorId,
  //     VoidCallback? onRemoved,
  //   }) async {
  //     try {
  //       await _userAuthRepo.removeFromFavorites(vendorId: vendorId);
  //       onRemoved?.call();
  //       if (context.mounted) {
  //         await AuthService().fetchProfile(context);
  //       }
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //     }
  //   }
}

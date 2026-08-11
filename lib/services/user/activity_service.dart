import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/model/activites/activity_frequency_model.dart';
import 'package:kena_emotional_journey/repository/activity_repository.dart';
import 'package:kena_emotional_journey/repository/user_home_repo.dart';

class ActivityService {
  ActivityService({
    ActivityRepository? repository,
    UserHomeRepository? userHomeRepo,
  }) : _repository = repository ?? ActivityRepository(),
       _userHomeRepo = userHomeRepo ?? UserHomeRepository();

  final ActivityRepository _repository;
  final UserHomeRepository _userHomeRepo;

  Future<bool> addPlannedActivities({
    required BuildContext context,
    required List<ActivityFrequency> activities,
  }) async {
    try {
      for (final activity in activities) {
        await _repository.addPlannedActivity(data: activity.toRequestJson());
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: 'ActivityService');
      }
      return false;
    }
  }

  /// Edit a selection (today) activity name.
  Future<bool> editSelectionActivity({
    required BuildContext context,
    required String id,
    required String newName,
  }) async {
    try {
      final response = await _userHomeRepo.updateTodayActivity(
        data: {"id": id, "newName": newName},
      );

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to update activity',
            serviceName: 'ActivityService',
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: 'ActivityService');
      }
      return false;
    }
  }

  /// Edit a planned activity (rename + optional schedule update).
  Future<bool> editPlannedActivity({
    required BuildContext context,
    required String id,
    required String newName,
    String? frequency,
    List<int>? weeklyDays,
    List<int>? monthlyDays,
    int? monthlyWeekDay,
    int? monthlyWeekNumber,
  }) async {
    try {
      final data = <String, dynamic>{"id": id, "name": newName};

      if (frequency != null) data["frequency"] = frequency;
      if (weeklyDays != null && weeklyDays.isNotEmpty) {
        data["weeklyDays"] = weeklyDays;
      }
      if (monthlyDays != null && monthlyDays.isNotEmpty) {
        data["monthlyDays"] = monthlyDays;
      }
      if (monthlyWeekDay != null) data["monthlyWeekDay"] = monthlyWeekDay;
      if (monthlyWeekNumber != null) {
        data["monthlyWeekNumber"] = monthlyWeekNumber;
      }

      final response = await _repository.editPlannedActivity(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to update planned activity',
            serviceName: 'ActivityService',
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: 'ActivityService');
      }
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/repository/forecast_repository.dart';

class ForecastService {
  ForecastService({ForecastRepository? repository})
      : _repository = repository ?? ForecastRepository();

  final ForecastRepository _repository;

  static const String _tag = 'ForecastService';

  /// Saves today's copied/selected forecast data.
  Future<bool> saveCopiedForecast({
    required BuildContext context,
    String? day,
    required List<Map<String, dynamic>> emotions,
    required String plan,
    required String notes,
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      final data = {
        if (day != null) 'day': day,
        'emotions': emotions,
        'plan': plan,
        'notes': notes,
        'activities': activities,
      };

      final response = await _repository.saveCopiedForecast(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to save forecast data',
            serviceName: _tag,
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: _tag);
      }
      return false;
    }
  }
}

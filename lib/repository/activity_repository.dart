import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class ActivityRepository {
  ActivityRepository({BaseApiServices? apiServices})
    : _apiServices = apiServices ?? NetworkApiService();

  final BaseApiServices _apiServices;

  Future<Map<String, dynamic>> addPlannedActivity({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(url: AppUrl.addPlannedActivity, data: data);
  }

  /// Edit a planned activity (rename + schedule update).
  Future<Map<String, dynamic>> editPlannedActivity({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.put(url: AppUrl.updatePlannedActivities, data: data);
  }
}

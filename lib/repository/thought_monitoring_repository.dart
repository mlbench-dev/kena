import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class ThoughtMonitoringRepository {
  ThoughtMonitoringRepository({BaseApiServices? apiServices})
    : _apiServices = apiServices ?? NetworkApiService();

  final BaseApiServices _apiServices;

  /// GET current thought monitoring settings (enabled flag + active hours).
  Future<Map<String, dynamic>> getSettings() {
    return _apiServices.get(url: AppUrl.thoughtMonitoringSettings);
  }

  /// PUT thought monitoring settings (enabled flag + active hours).
  Future<Map<String, dynamic>> saveSettings({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.put(url: AppUrl.thoughtMonitoringSettings, data: data);
  }

  /// POST the selected mood for a thought check-in.
  Future<Map<String, dynamic>> checkIn({required Map<String, dynamic> data}) {
    return _apiServices.post(url: AppUrl.thoughtMonitoringCheckIn, data: data);
  }

  /// GET today's recorded check-ins.
  Future<Map<String, dynamic>> getTodayCheckIns() {
    return _apiServices.get(url: AppUrl.thoughtMonitoringCheckInsToday);
  }
}

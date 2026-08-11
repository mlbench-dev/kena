import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class ForecastRepository {
  ForecastRepository({BaseApiServices? apiServices})
      : _apiServices = apiServices ?? NetworkApiService();

  final BaseApiServices _apiServices;

  /// Saves the copied/selected forecast data as today's forecast.
  Future<Map<String, dynamic>> saveCopiedForecast({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(
      url: AppUrl.saveCopiedForecast,
      data: data,
    );
  }
}

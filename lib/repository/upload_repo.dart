import 'dart:io';
import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class ImageRepository {
  final BaseApiServices api = NetworkApiService();

  Future<Map<String, dynamic>> uploadImage({required File file}) async {
    return api.multipartUpload(url: AppUrl.uploadImage, files: [file]);
  }
}

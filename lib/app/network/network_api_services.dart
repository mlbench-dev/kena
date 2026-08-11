import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kena_emotional_journey/app/data/exception/app_exceptions.dart';
import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';
import 'package:kena_emotional_journey/app/utils/log_manager.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

/// Class for handling network API requests.
class NetworkApiService implements BaseApiServices {
  final SessionController _sessionController = SessionController();

  // Do not use token in headers for the following API calls
  // final List<String> unauthenticatedEndpoints = [AppUrl.login, AppUrl.signup];
  final List<String> unauthenticatedEndpoints = [
    AppUrl.vendorLogin,
    AppUrl.vendorSignup,
    AppUrl.userLogin,
    AppUrl.userSignup,
    AppUrl.verifyVendorOtp,
    AppUrl.userOAuth,
    AppUrl.vendorOAuth,
  ];

  /// Utility method to check if API needs token in headers
  bool _needsAuth(String url) {
    return !unauthenticatedEndpoints.contains(url);
  }

  /// Utility function to handle errors and debugPrint stack traces
  void _handleError(dynamic error, {String? message, StackTrace? stackTrace}) {
    if (error is FormatException) {
      debugPrint('FormatException: $message');
      if (stackTrace != null) {
        debugPrint('Stack Trace: $stackTrace');
      }
      throw FetchDataException('Failed to parse response');
    } else if (error is SocketException) {
      debugPrint('SocketException: No Internet Connection');
      throw NoInternetException('No Internet Connection');
    } else if (error is TimeoutException) {
      debugPrint('TimeoutException: Network Request Timeout');
      throw FetchDataException('Network Request time out');
    } else {
      debugPrint('Unknown Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack Trace: $stackTrace');
      } else {
        debugPrint('No stack trace available');
      }
      throw FetchDataException('An unknown error occurred');
    }
  }

  /// Utility function for adding headers, including token if needed
  Map<String, String> _getHeaders(String url, {bool isMultipart = false}) {
    final Map<String, String> headers = {};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    final String? token = _sessionController.token;
    debugPrint('🔑 Token from session: $token');
    debugPrint('🔗 Request URL: $url');

    if (_needsAuth(url)) {
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ Authorization header added');
      } else {
        debugPrint(
          '⚠️ [NetworkApiService] Token is null for authenticated endpoint: $url — request will be rejected by server.',
        );
      }
    }

    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      } else if (decoded == null) {
        return {};
      } else {
        return {'data': decoded};
      }
    } catch (e) {
      _handleError(e, message: 'Error parsing response: ${response.body}');
      rethrow;
    }
  }

  /// Utility function for parsing the response and handling errors
  Map<String, dynamic> returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return _parseResponse(response);
      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw UnauthorizedException(response.body);
      case 500:
      case 404:
        throw FetchDataException(response.body);
      default:
        throw FetchDataException(response.body);
    }
  }

  /// Handles GET request
  @override
  Future<Map<String, dynamic>> get({required String url}) async {
    LogManager.logRequest('GET', url, null);

    final response = await http
        .get(Uri.parse(url), headers: _getHeaders(url))
        .timeout(const Duration(seconds: 60));

    LogManager.logResponse(response.statusCode.toString(), response.body);
    // This is handling all the errors so no need for try catch
    return returnResponse(response);
  }

  /// Handles POST request
  @override
  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? params,
  }) async {
    LogManager.logRequest('POST', url, data);

    final response = await http
        .post(Uri.parse(url), headers: _getHeaders(url), body: jsonEncode(data))
        .timeout(const Duration(seconds: 60));

    LogManager.logResponse(response.statusCode.toString(), response.body);
    return returnResponse(response);
  }

  /// Handles PUT request
  @override
  Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? params,
  }) async {
    LogManager.logRequest('PUT', url, data);

    final response = await http
        .put(Uri.parse(url), headers: _getHeaders(url), body: jsonEncode(data))
        .timeout(const Duration(seconds: 60));

    LogManager.logResponse(response.statusCode.toString(), response.body);
    return returnResponse(response);
  }

  /// Handles PATCH request
  @override
  Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? params,
  }) async {
    LogManager.logRequest('PATCH', url, data);

    final response = await http
        .patch(
          Uri.parse(url),
          headers: _getHeaders(url),
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 60));

    LogManager.logResponse(response.statusCode.toString(), response.body);
    return returnResponse(response);
  }

  /// Handles DELETE request
  @override
  Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    LogManager.logRequest('DELETE', url, data ?? {});

    final response = await http
        .delete(
          Uri.parse(url),
          headers: _getHeaders(url),
          body: data != null ? jsonEncode(data) : null,
        )
        .timeout(const Duration(seconds: 60));

    LogManager.logResponse(response.statusCode.toString(), response.body);
    return returnResponse(response);
  }

  /// Handles Multipart request
  @override
  Future<Map<String, dynamic>> multipartUpload({
    required String url,
    required List<File> files,
    String requestType = 'POST',
    String felid = 'image',
  }) async {
    LogManager.logRequest('$requestType (Multipart)', url, {
      'filePaths': files.map((f) => f.path).toList(),
      'fieldName': felid,
    });

    final request = http.MultipartRequest(requestType, Uri.parse(url));

    /// 🔥 IMPORTANT FIX: Do NOT pass Content-Type for multipart
    final headers = _getHeaders(url, isMultipart: true);
    headers.remove('Content-Type'); // ✅ critical fix
    request.headers.addAll(headers);

    for (final file in files) {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          felid,
          file.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
          filename: basename(file.path),
        ),
      );

      // LogManager.logDebug('Attaching file:', {
      //   'field': felid,
      //   'filename': basename(file.path),
      //   'path': file.path,
      //   'mimeType': mimeType,
      //   'size (bytes)': await file.length(),
      // });
    }

    // LogManager.logDebug('Final headers:', request.headers);
    // LogManager.logDebug('Total files attached:', request.files.length);

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 100),
      );

      final response = await http.Response.fromStream(streamedResponse);

      LogManager.logResponse(response.statusCode.toString(), response.body);

      return returnResponse(response);
    } catch (e) {
      // LogManager.logError('Exception during multipart upload:', e.toString());
      rethrow;
    }
  }

  @override
  String buildQueryString(Map<String, dynamic> params) {
    final queryParts = <String>[];

    params.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParts.add('$key=${Uri.encodeQueryComponent(value.toString())}');
      }
    });

    return queryParts.isEmpty ? '' : queryParts.join('&');
  }
}

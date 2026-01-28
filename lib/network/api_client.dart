import '../models/api_error.dart';

/// Abstract definition of the API Client
/// This allows us to swap between Dio, Http, or Mock implementations easily.
abstract class ApiClient {
  String get baseUrl;

  /// Update the base URL dynamically (e.g. for environment switching)
  void setBaseUrl(String url);

  /// Set the authentication token for subsequent requests
  void setAuthToken(String? token);

  /// Generic GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Generic POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Generic PUT request
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Generic DELETE request
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Generic PATCH request
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}

/// Exception thrown when the API returns an error response
class ApiException implements Exception {
  final ApiError error;
  final int? statusCode;

  ApiException(this.error, {this.statusCode});

  @override
  String toString() => 'ApiException: [${error.code}] ${error.message}';
}

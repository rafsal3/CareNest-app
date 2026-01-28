import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/api_error.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

class DioApiClient implements ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  String _baseUrl;

  DioApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    Dio? dio,
  }) : _baseUrl = baseUrl,
       _tokenStorage = tokenStorage {
    _dio = dio ?? Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _setupInterceptors();
  }

  @override
  String get baseUrl => _baseUrl;

  @override
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  @override
  void setAuthToken(String? token) {
    // This is handled dynamically by the interceptor, but if we wanted to set it globally:
    // if (token != null) {
    //   _dio.options.headers['Authorization'] = 'Bearer $token';
    // } else {
    //   _dio.options.headers.remove('Authorization');
    // }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Auth Token
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print(
              '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}',
            );
            print('Headers: ${options.headers}');
            print('Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '<-- ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
            );
            print('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print(
              '<-- Error ${e.response?.statusCode} ${e.requestOptions.baseUrl}${e.requestOptions.path}',
            );
            print('Message: ${e.message}');
            print('Response: ${e.response?.data}');
          }

          final apiError = _parseDioError(e);

          // Here we could handle 401 specifically to trigger a logout flow via a callback/stream
          if (e.response?.statusCode == 401) {
            // Potentially notify app to logout
            // For now just passing the error through
          }

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiException(apiError, statusCode: e.response?.statusCode),
            ),
          );
        },
      ),
    );
  }

  ApiError _parseDioError(DioException e) {
    try {
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        // Check for backend standardized error format
        if (data.containsKey('error') &&
            data['error'] is Map<String, dynamic>) {
          return ApiError.fromJson(data['error']);
        }
        // Fallback if error is at root or different format
        if (data.containsKey('message')) {
          return ApiError(
            code: 'API_ERROR',
            message: data['message'].toString(),
          );
        }
      }
      return ApiError(
        code: 'NETWORK_ERROR',
        message: e.message ?? 'Unknown network error',
      );
    } catch (_) {
      return const ApiError(
        code: 'PARSE_ERROR',
        message: 'Failed to parse error response',
      );
    }
  }

  // --- REST Implementation ---

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw _parseDioError(e); // Should be caught by interceptor usually
    } catch (e) {
      throw ApiException(ApiError(code: 'UNKNOWN', message: e.toString()));
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(ApiError(code: 'UNKNOWN', message: e.toString()));
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(ApiError(code: 'UNKNOWN', message: e.toString()));
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(ApiError(code: 'UNKNOWN', message: e.toString()));
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(ApiError(code: 'UNKNOWN', message: e.toString()));
    }
  }
}

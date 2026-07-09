import 'package:dio/dio.dart';

/// HTTP API client wrapper using Dio.
///
/// Handles external API calls (e.g., Google Maps Directions,
/// payment gateways) with base configuration.
class ApiClient {
  ApiClient({String? baseUrl, Map<String, dynamic>? headers})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? '',
          headers: headers,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }
}

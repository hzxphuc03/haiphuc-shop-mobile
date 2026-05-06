import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final _storage = const FlutterSecureStorage();
  final _cookieJar = CookieJar();

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      // Important for cross-origin cookie handling
      extra: {'withCredentials': true},
    ));

    // Add Cookie Manager
    dio.interceptors.add(CookieManager(_cookieJar));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Fallback: Still try to read token from storage if it exists
        final token = await _storage.read(key: 'access_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('DEBUG: [REQUEST] ${options.method} ${options.path}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('DEBUG: [RESPONSE] ${response.statusCode} from ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('DEBUG: [ERROR] ${e.response?.statusCode} for ${e.requestOptions.path}');
          print('DEBUG: Message: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: false,
        responseHeader: true,
        responseBody: true,
      ));
    }
  }
}

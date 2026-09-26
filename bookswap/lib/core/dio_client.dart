import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static Dio? _dio;
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://bookswap-backend-eygy.onrender.com',
  );

  static String buildMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final normalized = path.replaceAll('\\', '/');
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = normalized.startsWith('/') ? normalized : '/$normalized';
    return '$cleanBase$cleanPath';
  }

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            if (e.response?.statusCode == 401) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              _dio?.options.headers.remove('Authorization');
            }
            return handler.next(e);
          },
        ),
      );
    }

    return _dio!;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _dio?.options.headers.remove('Authorization');
  }
}

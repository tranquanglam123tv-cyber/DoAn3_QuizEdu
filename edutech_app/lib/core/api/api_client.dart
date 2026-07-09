import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static String get baseUrl {
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty && envUrl != 'dynamic') {
      return envUrl;
    }
    // Auto-detect for mobile platforms
    if (!kIsWeb && Platform.isAndroid) {
      // Physical device needs actual IP address of the host machine
      return 'http://192.168.1.24:8081/api';
    }
    if (!kIsWeb && Platform.isIOS) {
      // iOS simulator uses localhost
      return 'http://localhost:8081/api';
    }
    // Web and fallback
    return 'http://localhost:8081/api';
  }

  // Helper: convert backend URL to accessible URL based on platform
  static String fixAvatarUrl(String url) {
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      // Replace localhost with appropriate host for the platform
      if (!kIsWeb && Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host localhost
        // Physical device needs actual IP - but we can't detect it here
        // The backend should return the correct URL
        return url;
      }
      return url;
    }
    // If it's already an IP address (like 192.168.x.x), it's probably correct
    return url;
  }

  static final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = baseUrl;
          final token = await TokenStorage.get();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );

  static Dio get dio => _dio;
}

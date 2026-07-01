import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

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

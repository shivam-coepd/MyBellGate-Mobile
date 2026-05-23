import 'package:dio/dio.dart';
import 'package:mygate_coepd/config/app_config.dart';

class ApiService {
  // Use local backend URL. If running in Android emulator, 10.0.2.2 points to localhost.
  // static const String baseUrl = 'http://10.0.2.2/api';
  static const String baseUrl = 'https://app.mygatebell.com/backend';

  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = AppConfig.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class ApiClient {
  static final ApiClient _instancia = ApiClient._interno();
  factory ApiClient() => _instancia;

  late final Dio dio;
  final StorageService _storageService = StorageService();
  Future<void> Function()? onSesionExpirada;

  ApiClient._interno() {
    String baseUrl = 'http://localhost:3000/api';
    if (dotenv.isInitialized && dotenv.env['API_BASE_URL'] != null) {
      baseUrl = dotenv.env['API_BASE_URL']!;
    }

    dio = Dio(
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.obtenerToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final path = e.requestOptions.path;
            if (!path.contains('/auth/login')) {
              if (onSesionExpirada != null) {
                await onSesionExpirada!();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}

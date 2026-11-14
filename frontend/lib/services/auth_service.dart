import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instancia = AuthService._interno();
  factory AuthService() => _instancia;

  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();

  Usuario? _usuarioActual;
  bool _autenticado = false;
  bool _inicializado = false;
  String? _mensajeExpirado;

  Usuario? get usuarioActual => _usuarioActual;
  bool get autenticado => _autenticado;
  bool get inicializado => _inicializado;
  String? get mensajeExpirado => _mensajeExpirado;

  AuthService._interno() {
    _apiClient.onSesionExpirada = _manejarSesionExpirada;
  }

  void limpiarMensajeExpirado() {
    _mensajeExpirado = null;
  }

  Future<void> _manejarSesionExpirada() async {
    await _storageService.limpiarTodo();
    _usuarioActual = null;
    _autenticado = false;
    _mensajeExpirado = 'Tu sesion ha expirado o el token es invalido. Por favor inicia sesion nuevamente.';
    notifyListeners();
  }

  Future<void> login(String correo, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'correo': correo.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token']?.toString() ?? '';
        final usuarioData = response.data['usuario'] as Map<String, dynamic>;
        final usuario = Usuario.fromJson(usuarioData);

        await _storageService.guardarToken(token);
        await _storageService.guardarUsuario(usuario);

        _usuarioActual = usuario;
        _autenticado = true;
        _mensajeExpirado = null;
        notifyListeners();
      }
    } on DioException catch (e) {
      throw _procesarErrorAuth(e);
    } catch (e) {
      throw Exception('Error inesperado al iniciar sesion: $e');
    }
  }

  Future<void> cerrarSesion() async {
    await _storageService.limpiarTodo();
    _usuarioActual = null;
    _autenticado = false;
    _mensajeExpirado = null;
    notifyListeners();
  }

  Future<bool> verificarSesion() async {
    try {
      final tieneToken = await _storageService.tieneToken();
      if (!tieneToken) {
        _usuarioActual = null;
        _autenticado = false;
        _inicializado = true;
        notifyListeners();
        return false;
      }

      final response = await _apiClient.dio.get('/auth/perfil');
      if (response.statusCode == 200) {
        Map<String, dynamic> datosUsuario;
        if (response.data is Map<String, dynamic> && response.data['usuario'] != null) {
          datosUsuario = response.data['usuario'] as Map<String, dynamic>;
        } else {
          datosUsuario = response.data as Map<String, dynamic>;
        }
        final usuario = Usuario.fromJson(datosUsuario);
        await _storageService.guardarUsuario(usuario);
        _usuarioActual = usuario;
        _autenticado = true;
        _inicializado = true;
        notifyListeners();
        return true;
      } else {
        await _storageService.limpiarTodo();
        _usuarioActual = null;
        _autenticado = false;
        _inicializado = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      await _storageService.limpiarTodo();
      _usuarioActual = null;
      _autenticado = false;
      _inicializado = true;
      notifyListeners();
      return false;
    }
  }

  Future<bool> tieneTokenAlmacenado() async {
    return await _storageService.tieneToken();
  }

  String _procesarErrorAuth(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
      if (e.response?.statusCode == 401) {
        return 'Credenciales incorrectas. Verifica tu correo y contrasena.';
      }
      return 'Error ${e.response?.statusCode}: ${e.response?.statusMessage ?? "Error del servidor"}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de conexion agotado. Revisa que el backend este encendido.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor. Verifica la URL base en el archivo .env.';
    }
    return e.message ?? 'Error de conexion';
  }
}

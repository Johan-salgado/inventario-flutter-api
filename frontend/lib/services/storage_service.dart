import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class StorageService {
  static const String _keyToken = 'access_token';
  static const String _keyUsuarioId = 'usuario_id';
  static const String _keyUsuarioNombre = 'usuario_nombre';
  static const String _keyUsuarioCorreo = 'usuario_correo';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> guardarToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> obtenerToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> eliminarToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  Future<bool> tieneToken() async {
    final token = await _secureStorage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    if (usuario.id != null) {
      await prefs.setInt(_keyUsuarioId, usuario.id!);
    }
    await prefs.setString(_keyUsuarioNombre, usuario.nombre);
    await prefs.setString(_keyUsuarioCorreo, usuario.correo);
  }

  Future<Usuario?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString(_keyUsuarioNombre);
    final correo = prefs.getString(_keyUsuarioCorreo);
    final id = prefs.getInt(_keyUsuarioId);

    if (nombre == null || correo == null) {
      return null;
    }

    return Usuario(
      id: id,
      nombre: nombre,
      correo: correo,
    );
  }

  Future<void> eliminarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioId);
    await prefs.remove(_keyUsuarioNombre);
    await prefs.remove(_keyUsuarioCorreo);
  }

  Future<void> limpiarTodo() async {
    await eliminarToken();
    await eliminarUsuario();
  }
}

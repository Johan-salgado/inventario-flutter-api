// lib/services/producto_service.dart
// Servicio para manejar toda la comunicacion HTTP con el backend mediante Dio

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/producto.dart';

class ProductoService {
  late final Dio _dio;

  ProductoService() {
    // Obtenemos la URL base desde el archivo .env usando flutter_dotenv
    // Si dotenv no esta inicializado o no existe la variable, usamos localhost por defecto
    String baseUrl = 'http://localhost:3000/api';
    if (dotenv.isInitialized) {
      baseUrl = dotenv.env['API_BASE_URL'] ?? baseUrl;
    }

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
  }

  // 1. Obtener todos los productos (GET /api/productos)
  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await _dio.get('/productos');

      if (response.statusCode == 200) {
        final List<dynamic> datos = response.data;
        return datos.map((item) => Producto.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener productos: Codigo ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _procesarErrorDio(e, 'Error al cargar los productos');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // 2. Obtener un producto por su ID (GET /api/productos/:id)
  Future<Producto> obtenerProductoPorId(int id) async {
    try {
      final response = await _dio.get('/productos/$id');

      if (response.statusCode == 200) {
        return Producto.fromJson(response.data);
      } else {
        throw Exception('No se encontro el producto con ID $id');
      }
    } on DioException catch (e) {
      throw _procesarErrorDio(e, 'Error al consultar detalle del producto');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // 3. Registrar un nuevo producto (POST /api/productos)
  Future<Producto> crearProducto(Producto producto) async {
    try {
      final response = await _dio.post(
        '/productos',
        data: producto.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Producto.fromJson(response.data);
      } else {
        throw Exception('Error al registrar el producto');
      }
    } on DioException catch (e) {
      throw _procesarErrorDio(e, 'Error al guardar el nuevo producto');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // 4. Actualizar un producto existente (PUT /api/productos/:id)
  Future<Producto> actualizarProducto(int id, Producto producto) async {
    try {
      final response = await _dio.put(
        '/productos/$id',
        data: producto.toJson(),
      );

      if (response.statusCode == 200) {
        return Producto.fromJson(response.data);
      } else {
        throw Exception('Error al actualizar el producto');
      }
    } on DioException catch (e) {
      throw _procesarErrorDio(e, 'Error al actualizar el producto');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // 5. Eliminar un producto (DELETE /api/productos/:id)
  Future<void> eliminarProducto(int id) async {
    try {
      final response = await _dio.delete('/productos/$id');

      if (response.statusCode != 200) {
        throw Exception('No se pudo eliminar el producto');
      }
    } on DioException catch (e) {
      throw _procesarErrorDio(e, 'Error al eliminar el producto');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Metodo auxiliar para procesar y formatear errores de Dio
  String _procesarErrorDio(DioException e, String mensajePorDefecto) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
      return 'Error ${e.response?.statusCode}: ${e.response?.statusMessage ?? mensajePorDefecto}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de conexion agotado. Revisa que el backend este encendido.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor. Verifica la URL base en el archivo .env.';
    }
    return e.message ?? mensajePorDefecto;
  }
}

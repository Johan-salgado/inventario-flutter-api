import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/models/producto.dart';
import 'package:inventario_app/models/usuario.dart';

void main() {
  group('Pruebas unitarias del Modelo Producto', () {
    test('Debe crear un Producto correctamente desde un Map JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Teclado Mecanico',
        'codigo': 'TEC-001',
        'descripcion': 'Teclado con switches azules',
        'precio': 150000.0,
        'cantidad': 10,
        'categoria': 'Accesorios',
      };

      final producto = Producto.fromJson(json);

      expect(producto.id, 1);
      expect(producto.nombre, 'Teclado Mecanico');
      expect(producto.codigo, 'TEC-001');
      expect(producto.precio, 150000.0);
      expect(producto.cantidad, 10);
      expect(producto.categoria, 'Accesorios');
      expect(producto.valorTotalInventario, 1500000.0);
    });

    test('Debe convertir un Producto a Map JSON correctamente', () {
      final producto = Producto(
        id: 2,
        nombre: 'Mouse Optico',
        codigo: 'MOU-002',
        descripcion: 'Mouse USB',
        precio: 45000.0,
        cantidad: 5,
        categoria: 'Accesorios',
      );

      final json = producto.toJson();

      expect(json['id'], 2);
      expect(json['nombre'], 'Mouse Optico');
      expect(json['codigo'], 'MOU-002');
      expect(json['precio'], 45000.0);
      expect(json['cantidad'], 5);
      expect(json['categoria'], 'Accesorios');
    });
  });

  group('Pruebas unitarias del Modelo Usuario', () {
    test('Debe crear un Usuario correctamente desde un Map JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Administrador',
        'correo': 'admin@inventario.com',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, 1);
      expect(usuario.nombre, 'Administrador');
      expect(usuario.correo, 'admin@inventario.com');
    });

    test('Debe convertir un Usuario a Map JSON correctamente', () {
      final usuario = Usuario(
        id: 2,
        nombre: 'Johan Salgado',
        correo: 'johan@inventario.com',
      );

      final json = usuario.toJson();

      expect(json['id'], 2);
      expect(json['nombre'], 'Johan Salgado');
      expect(json['correo'], 'johan@inventario.com');
    });
  });
}

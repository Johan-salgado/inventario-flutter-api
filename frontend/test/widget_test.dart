// test/widget_test.dart
// Pruebas unitarias para el modelo Producto

import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_app/models/producto.dart';

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
      expect(producto.valorTotalInventario, 1500000.0); // 150000 * 10
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
}

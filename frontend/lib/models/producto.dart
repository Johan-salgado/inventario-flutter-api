// lib/models/producto.dart
// Modelo que representa la entidad Producto solicitada en el parcial

class Producto {
  final int? id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  Producto({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion = '',
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  // Constructor factory para deserializar la respuesta JSON de la API
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nombre: json['nombre']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: json['precio'] != null
          ? double.tryParse(json['precio'].toString()) ?? 0.0
          : 0.0,
      cantidad: json['cantidad'] != null
          ? int.tryParse(json['cantidad'].toString()) ?? 0
          : 0,
      categoria: json['categoria']?.toString() ?? '',
    );
  }

  // Metodo para serializar el objeto a JSON para peticiones POST y PUT
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    };
  }

  // Calculo del valor total del producto (precio * cantidad)
  double get valorTotalInventario => precio * cantidad;
}

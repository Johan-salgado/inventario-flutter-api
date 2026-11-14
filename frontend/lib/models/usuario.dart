class Usuario {
  final int? id;
  final String nombre;
  final String correo;

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nombre: json['nombre']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
    };
  }
}

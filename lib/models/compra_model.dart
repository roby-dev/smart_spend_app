class Compra {
  final int? id;
  final String titulo;
  final DateTime fecha;
  final List<String> nombresDetalles; // Nueva propiedad

  Compra({
    this.id,
    required this.titulo,
    required this.fecha,
    this.nombresDetalles = const [], // Inicializa como una lista vacía
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
      };

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
        id: json['id'],
        titulo: json['titulo'],
        fecha: DateTime.parse(json['fecha']),
      );

  Compra copyWith({
    int? id,
    String? titulo,
    DateTime? fecha,
    List<String>? nombresDetalles, // Nuevo parámetro opcional
  }) {
    return Compra(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      nombresDetalles:
          nombresDetalles ?? this.nombresDetalles, // Usar el nuevo parámetro
    );
  }
}

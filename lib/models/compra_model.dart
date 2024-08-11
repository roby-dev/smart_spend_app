import 'package:smart_spend_app/models/compra_detalle_model.dart';

class Compra {
  final int? id;
  final String titulo;
  final DateTime fecha;
  final List<CompraDetalle> detalles; // Nueva propiedad

  Compra({
    this.id,
    required this.titulo,
    required this.fecha,
    this.detalles = const [], // Inicializa como una lista vacía
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
    List<CompraDetalle>? detalles, // Nuevo parámetro opcional
  }) {
    return Compra(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      detalles: detalles ?? this.detalles, // Usar el nuevo parámetro
    );
  }
}

import 'package:smart_spend_app/models/compra_detalle_model.dart';

class CompraModel {
  final int? id;
  final String titulo;
  final DateTime fecha;
  List<CompraDetalleModel> detalles; // Nueva propiedad

  CompraModel({
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

  Map<String, dynamic> toJsonExport() {
    return {
      'id': id,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'detalles': detalles
          .map((detalle) => detalle.toJson())
          .toList(), // Incluir detalles en el JSON
    };
  }

  factory CompraModel.fromJson(Map<String, dynamic> json) => CompraModel(
        id: json['id'],
        titulo: json['titulo'],
        fecha: DateTime.parse(json['fecha']),
      );

  CompraModel copyWith({
    int? id,
    String? titulo,
    DateTime? fecha,
    List<CompraDetalleModel>? detalles, // Nuevo parámetro opcional
  }) {
    return CompraModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      detalles: detalles ?? this.detalles, // Usar el nuevo parámetro
    );
  }
}

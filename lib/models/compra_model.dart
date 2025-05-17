import 'package:smart_spend_app/models/compra_detalle_model.dart';

class CompraModel {
  final int? id;
  final String titulo;
  final DateTime fecha;
  List<CompraDetalleModel> detalles;
  final bool archivado;

  CompraModel({
    this.id,
    required this.titulo,
    required this.fecha,
    this.detalles = const [],
    this.archivado = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'archivado': archivado
      };

  Map<String, dynamic> toJsonExport() {
    return {
      'id': id,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'archivado': archivado,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }

  factory CompraModel.fromJson(Map<String, dynamic> json) => CompraModel(
        id: json['id'],
        titulo: json['titulo'],
        fecha: DateTime.parse(json['fecha']),
        archivado: json['archivado'] ?? false,
      );

  CompraModel copyWith({
    int? id,
    String? titulo,
    DateTime? fecha,
    List<CompraDetalleModel>? detalles,
    bool? archivado,
  }) {
    return CompraModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      detalles: detalles ?? this.detalles,
      archivado: archivado ?? this.archivado,
    );
  }
}

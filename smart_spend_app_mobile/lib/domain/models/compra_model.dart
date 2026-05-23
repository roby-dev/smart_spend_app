import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';

class CompraModel {
  final int? id;
  final String titulo;
  final DateTime fecha;
  List<CompraDetalleModel> detalles;
  final bool archivado;
  final double? presupuesto;
  final int orden;

  CompraModel({
    this.id,
    required this.titulo,
    required this.fecha,
    this.detalles = const [],
    this.archivado = false,
    this.presupuesto,
    this.orden = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'archivado': archivado,
        'presupuesto': presupuesto,
        'orden': orden,
      };

  Map<String, dynamic> toJsonExport() {
    return {
      'id': id,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'archivado': archivado,
      'presupuesto': presupuesto,
      'orden': orden,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }

  factory CompraModel.fromJson(Map<String, dynamic> json) => CompraModel(
        id: json['id'],
        titulo: json['titulo'],
        fecha: DateTime.parse(json['fecha']),
        archivado: json['archivado'] ?? false,
        presupuesto: (json['presupuesto'] as num?)?.toDouble(),
        orden: json['orden'] ?? 0,
      );

  CompraModel copyWith({
    int? id,
    String? titulo,
    DateTime? fecha,
    List<CompraDetalleModel>? detalles,
    bool? archivado,
    double? presupuesto,
    int? orden,
  }) {
    return CompraModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      detalles: detalles ?? this.detalles,
      archivado: archivado ?? this.archivado,
      presupuesto: presupuesto ?? this.presupuesto,
      orden: orden ?? this.orden,
    );
  }
}

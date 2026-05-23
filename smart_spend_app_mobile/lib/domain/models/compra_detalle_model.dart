class CompraDetalleModel {
  final int? id;
  final String nombre;
  final double precio;
  final int compraId;
  final DateTime fecha;

  CompraDetalleModel(
      {this.id,
      required this.nombre,
      required this.precio,
      required this.compraId,
      required this.fecha});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'compra_id': compraId,
        'fecha': fecha.toIso8601String(),
      };

  factory CompraDetalleModel.fromJson(Map<String, dynamic> json) =>
      CompraDetalleModel(
        id: json['id'],
        nombre: json['nombre'],
        precio: json['precio'],
        compraId: json['compra_id'],
        fecha: DateTime.parse(json['fecha']),
      );

  CompraDetalleModel copyWith(
      {int? id,
      String? nombre,
      double? precio,
      int? compraId,
      DateTime? fecha}) {
    return CompraDetalleModel(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        precio: precio ?? this.precio,
        compraId: compraId ?? this.compraId,
        fecha: fecha ?? this.fecha);
  }
}

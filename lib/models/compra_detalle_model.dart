class CompraDetalle {
  final int? id;
  final String nombre;
  final double precio;
  final int compraId;

  CompraDetalle(
      {this.id,
      required this.nombre,
      required this.precio,
      required this.compraId});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'compra_id': compraId,
      };

  factory CompraDetalle.fromJson(Map<String, dynamic> json) => CompraDetalle(
        id: json['id'],
        nombre: json['nombre'],
        precio: json['precio'],
        compraId: json['compra_id'],
      );

  CompraDetalle copyWith(
      {int? id, String? nombre, double? precio, int? compraId}) {
    return CompraDetalle(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      compraId: compraId ?? this.compraId,
    );
  }
}

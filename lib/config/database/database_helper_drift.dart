import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database_helper_drift.g.dart';

@DataClassName('Compra')
class Compras extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  TextColumn get fecha => text()();
}

@DataClassName('CompraDetalle')
class CompraDetalles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  RealColumn get precio => real()();
  TextColumn get fecha => text()();

  @ReferenceName('compras')
  IntColumn get compra => integer().references(Compras, #id)();
}

// Crea la base de datos
@DriftDatabase(tables: [Compras, CompraDetalles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Métodos CRUD
  Future<int> insertCompra(ComprasCompanion compra) =>
      into(compras).insert(compra);

  Future<int> insertCompraDetalle(CompraDetallesCompanion detalle) =>
      into(compraDetalles).insert(detalle);

  Future<List<Compra>> getCompras() => select(compras).get();

  Future<List<CompraDetalle>> getCompraDetalles(int compraId) =>
      (select(compraDetalles)..where((tbl) => tbl.compra.equals(compraId)))
          .get();

  Future<void> deleteCompra(int id) async {
    await (delete(compraDetalles)..where((tbl) => tbl.compra.equals(id))).go();
    await (delete(compras)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteCompraDetalle(int id) async {
    await (delete(compraDetalles)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateCompra(ComprasCompanion compra) {
    return update(compras).replace(compra);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

extension DriftExportImport on AppDatabase {
  Future<String> exportToJson() async {
    final comprasList = await select(compras).get();
    final List<Map<String, dynamic>> comprasWithDetails = [];

    for (var compra in comprasList) {
      final detalles = await (select(compraDetalles)
            ..where((tbl) => tbl.compra.equals(compra.id)))
          .get();

      comprasWithDetails.add({
        'compra': compra.toJson(),
        'detalles': detalles.map((d) => d.toJson()).toList(),
      });
    }

    return jsonEncode(comprasWithDetails);
  }

  Future<void> importFromJson(String jsonString) async {
    final List<dynamic> decoded = jsonDecode(jsonString);

    for (var compraMap in decoded) {
      final compraData = compraMap['compra'] as Map<String, dynamic>;
      final compraId = await into(compras).insert(ComprasCompanion(
        titulo: Value(compraData['titulo']),
        fecha: Value(compraData['fecha']),
      ));

      final detalles = compraMap['detalles'] as List<dynamic>;
      for (var detalleMap in detalles) {
        await into(compraDetalles).insert(CompraDetallesCompanion(
          nombre: Value(detalleMap['nombre']),
          precio: Value(detalleMap['precio']),
          compra: Value(compraId),
          fecha: Value(detalleMap['fecha']),
        ));
      }
    }
  }
}

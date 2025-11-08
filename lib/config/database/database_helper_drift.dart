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
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
  RealColumn get presupuesto => real().nullable()();
  IntColumn get orden => integer().withDefault(const Constant(0))();
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
    final List<Map<String, dynamic>> exportData = [];

    for (var compra in comprasList) {
      final detalles = await (select(compraDetalles)
            ..where((tbl) => tbl.compra.equals(compra.id)))
          .get();

      exportData.add({
        'titulo': compra.titulo,
        'fecha': compra.fecha,
        'archivado': compra.archivado,
        'presupuesto': compra.presupuesto,
        'orden': compra.orden,
        'detalles': detalles
            .map((d) => {
                  'nombre': d.nombre,
                  'precio': d.precio,
                  'fecha': d.fecha,
                })
            .toList(),
      });
    }

    return jsonEncode(exportData);
  }

  Future<void> importFromJson(String jsonString) async {
    final List<dynamic> decoded = jsonDecode(jsonString);

    for (int i = 0; i < decoded.length; i++) {
      final compraMap = decoded[i];
      final compraId = await into(compras).insert(ComprasCompanion(
        titulo: Value(compraMap['titulo']),
        fecha: Value(compraMap['fecha']),
        archivado: Value(compraMap['archivado'] ?? false), // por defecto
        presupuesto: Value(compraMap['presupuesto']), // no existía
        orden: Value(i), // basado en posición
      ));

      final detalles = compraMap['detalles'] as List<dynamic>;
      for (var detalleMap in detalles) {
        await into(compraDetalles).insert(CompraDetallesCompanion(
          nombre: Value(detalleMap['nombre']),
          precio: Value((detalleMap['precio'] as num).toDouble()),
          compra: Value(compraId),
          fecha: Value(detalleMap['fecha']),
        ));
      }
    }
  }
}

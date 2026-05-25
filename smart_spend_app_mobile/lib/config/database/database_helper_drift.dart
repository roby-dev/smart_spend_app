import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database_helper_drift.g.dart';

@DataClassName('Compra')
class Compras extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()();
  TextColumn get titulo => text()();
  TextColumn get fecha => text()();
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
  RealColumn get presupuesto => real().nullable()();
  IntColumn get orden => integer().withDefault(const Constant(0))();
}

@DataClassName('CompraDetalle')
class CompraDetalles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().nullable()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from == 1 && to == 2) {
          await m.addColumn(compras, compras.uuid);
          await m.addColumn(compraDetalles, compraDetalles.uuid);
        }
      },
    );
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
  Future<String> exportToJson({List<int>? ids}) async {
    final query = select(compras);
    if (ids != null && ids.isNotEmpty) {
      query.where((tbl) => tbl.id.isIn(ids));
    }
    final comprasList = await query.get();
    final List<Map<String, dynamic>> exportData = [];

    for (var compra in comprasList) {
      String compraUuid = compra.uuid ?? '';
      if (compraUuid.isEmpty) {
        compraUuid = const Uuid().v7();
        await update(compras).replace(ComprasCompanion(
          id: Value(compra.id),
          uuid: Value(compraUuid),
        ));
      }

      final detalles = await (select(compraDetalles)
            ..where((tbl) => tbl.compra.equals(compra.id)))
          .get();

      final List<Map<String, dynamic>> detallesExport = [];
      for (var d in detalles) {
        String detalleUuid = d.uuid ?? '';
        if (detalleUuid.isEmpty) {
          detalleUuid = const Uuid().v7();
          await update(compraDetalles).replace(CompraDetallesCompanion(
            id: Value(d.id),
            uuid: Value(detalleUuid),
          ));
        }
        detallesExport.add({
          'uuid': detalleUuid,
          'nombre': d.nombre,
          'precio': d.precio,
          'fecha': d.fecha,
        });
      }

      exportData.add({
        'uuid': compraUuid,
        'titulo': compra.titulo,
        'fecha': compra.fecha,
        'archivado': compra.archivado,
        'presupuesto': compra.presupuesto,
        'orden': compra.orden,
        'detalles': detallesExport,
      });
    }

    return jsonEncode(exportData);
  }

  Future<void> importFromJson(String jsonString) async {
    final List<dynamic> decoded = jsonDecode(jsonString);

    decoded.sort((a, b) =>
        (a['fecha'] as String).compareTo(b['fecha'] as String));

    // Build map of existing compras by UUID for dedup
    final existingCompras = await select(compras).get();
    final Map<String, Compra> compraByUuid = {};
    for (var c in existingCompras) {
      if (c.uuid != null && c.uuid!.isNotEmpty) {
        compraByUuid[c.uuid!] = c;
      }
    }

    final maxOrdenExpr = compras.orden.max();
    final maxOrdenQuery = selectOnly(compras)..addColumns([maxOrdenExpr]);
    final currentMax = await maxOrdenQuery
        .map((row) => row.read(maxOrdenExpr))
        .getSingleOrNull();
    var nextOrden = (currentMax ?? -1) + 1;

    for (int i = 0; i < decoded.length; i++) {
      final compraMap = decoded[i];
      final incomingUuid = compraMap['uuid'] as String?;

      int compraId;
      if (incomingUuid != null &&
          incomingUuid.isNotEmpty &&
          compraByUuid.containsKey(incomingUuid)) {
        // Update existing compra by UUID (last-write-wins)
        final existing = compraByUuid[incomingUuid]!;
        compraId = existing.id;

        await update(compras).replace(ComprasCompanion(
          id: Value(compraId),
          uuid: Value(incomingUuid),
          titulo: Value(compraMap['titulo']),
          fecha: Value(compraMap['fecha']),
          archivado: Value(compraMap['archivado'] ?? false),
          presupuesto: Value((compraMap['presupuesto'] as num?)?.toDouble()),
          orden: Value(existing.orden),
        ));

        // Delete old detalles and re-insert
        await (delete(compraDetalles)
              ..where((tbl) => tbl.compra.equals(compraId)))
            .go();
      } else {
        // Insert new compra — generate UUIDv7 if absent
        final newUuid = (incomingUuid != null && incomingUuid.isNotEmpty)
            ? incomingUuid
            : const Uuid().v7();
        compraId = await into(compras).insert(ComprasCompanion(
          uuid: Value(newUuid),
          titulo: Value(compraMap['titulo']),
          fecha: Value(compraMap['fecha']),
          archivado: Value(compraMap['archivado'] ?? false),
          presupuesto: Value((compraMap['presupuesto'] as num?)?.toDouble()),
          orden: Value(nextOrden++),
        ));
      }

      final detalles = compraMap['detalles'] as List<dynamic>;
      for (var detalleMap in detalles) {
        final detalleUuid = detalleMap['uuid'] as String?;
        final newDetalleUuid = (detalleUuid != null && detalleUuid.isNotEmpty)
            ? detalleUuid
            : const Uuid().v7();
        await into(compraDetalles).insert(CompraDetallesCompanion(
          uuid: Value(newDetalleUuid),
          nombre: Value(detalleMap['nombre']),
          precio: Value((detalleMap['precio'] as num).toDouble()),
          compra: Value(compraId),
          fecha: Value(detalleMap['fecha']),
        ));
      }
    }
  }
}

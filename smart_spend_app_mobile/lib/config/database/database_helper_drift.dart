import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:smart_spend_app/domain/models/import_result.dart';

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

  /// Test-only constructor. Lets unit tests inject an in-memory
  /// [QueryExecutor] (e.g. `NativeDatabase.memory()`) instead of the
  /// file-backed connection. Not used by the running app.
  AppDatabase.forTesting(super.executor);

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

  Future<ImportResult> importFromJson(String jsonString) async {
    final List<dynamic> decoded = jsonDecode(jsonString);

    // Null-safe sort: a record missing `fecha` must not abort the whole batch.
    decoded.sort((a, b) {
      final fa = (a['fecha'] as String?) ?? '';
      final fb = (b['fecha'] as String?) ?? '';
      return fa.compareTo(fb);
    });

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

    var imported = 0;
    final failures = <ImportFailure>[];

    for (int i = 0; i < decoded.length; i++) {
      final compraMap = decoded[i] as Map<String, dynamic>;
      final titulo = (compraMap['titulo'] as String?)?.trim();
      final displayTitulo =
          (titulo == null || titulo.isEmpty) ? '(sin nombre)' : titulo;

      final incomingUuid = compraMap['uuid'] as String?;
      final isUpdate = incomingUuid != null &&
          incomingUuid.isNotEmpty &&
          compraByUuid.containsKey(incomingUuid);
      final ordenForInsert = nextOrden;

      try {
        // Each compra imports in its own transaction: a malformed record is
        // rolled back cleanly and skipped, never leaving a half-imported row.
        await transaction(() async {
          _validateCompraMap(compraMap);

          int compraId;
          if (isUpdate) {
            // Update existing compra by UUID (last-write-wins)
            final existing = compraByUuid[incomingUuid]!;
            compraId = existing.id;

            await update(compras).replace(ComprasCompanion(
              id: Value(compraId),
              uuid: Value(incomingUuid),
              titulo: Value(compraMap['titulo']),
              fecha: Value(compraMap['fecha']),
              archivado: Value(compraMap['archivado'] ?? false),
              presupuesto:
                  Value((compraMap['presupuesto'] as num?)?.toDouble()),
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
              presupuesto:
                  Value((compraMap['presupuesto'] as num?)?.toDouble()),
              orden: Value(ordenForInsert),
            ));
          }

          final detalles = (compraMap['detalles'] as List<dynamic>?) ?? const [];
          for (var detalleMap in detalles) {
            final detalle = detalleMap as Map<String, dynamic>;
            _validateDetalleMap(detalle);
            final detalleUuid = detalle['uuid'] as String?;
            final newDetalleUuid =
                (detalleUuid != null && detalleUuid.isNotEmpty)
                    ? detalleUuid
                    : const Uuid().v7();
            await into(compraDetalles).insert(CompraDetallesCompanion(
              uuid: Value(newDetalleUuid),
              nombre: Value(detalle['nombre']),
              precio: Value((detalle['precio'] as num).toDouble()),
              compra: Value(compraId),
              fecha: Value(detalle['fecha']),
            ));
          }
        });

        // Only advance the orden counter when we actually inserted a new row.
        if (!isUpdate) nextOrden++;
        imported++;
      } catch (e) {
        failures.add(ImportFailure(titulo: displayTitulo, reason: _reasonFor(e)));
      }
    }

    return ImportResult(imported: imported, failures: failures);
  }

  void _validateCompraMap(Map<String, dynamic> compraMap) {
    if (compraMap['fecha'] is! String ||
        (compraMap['fecha'] as String).isEmpty) {
      throw const FormatException('la compra no tiene fecha');
    }
    // `titulo` must exist and be text, but an empty string is allowed:
    // the column is non-null and '' is valid (if odd) backup data.
    if (compraMap['titulo'] is! String) {
      throw const FormatException('la compra no tiene nombre');
    }
  }

  void _validateDetalleMap(Map<String, dynamic> detalle) {
    if (detalle['fecha'] is! String || (detalle['fecha'] as String).isEmpty) {
      throw const FormatException('un ítem no tiene fecha');
    }
    if (detalle['nombre'] is! String) {
      throw const FormatException('un ítem no tiene nombre');
    }
    if (detalle['precio'] is! num) {
      throw const FormatException('un ítem no tiene precio válido');
    }
  }

  String _reasonFor(Object error) {
    if (error is FormatException) return error.message;
    return error.toString();
  }
}

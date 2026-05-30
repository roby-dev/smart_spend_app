import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

/// Characterization tests for the backup export/import pipeline
/// (`DriftExportImport` on `AppDatabase`).
///
/// These lock in the CORRECT, intended behavior. They run against an
/// in-memory sqlite database, so they never touch the device DB.
void main() {
  // The round-trip test intentionally opens a second in-memory database.
  // They use independent executors, so the multi-database warning is noise.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Builds the JSON shape that `importFromJson` consumes.
  String jsonFor(List<Map<String, dynamic>> compras) => jsonEncode(compras);

  Map<String, dynamic> compraJson({
    String? uuid,
    String titulo = 'Super',
    String fecha = '2026-01-01T00:00:00.000',
    bool archivado = false,
    double? presupuesto,
    List<Map<String, dynamic>> detalles = const [],
  }) =>
      {
        'uuid': uuid,
        'titulo': titulo,
        'fecha': fecha,
        'archivado': archivado,
        'presupuesto': presupuesto,
        'detalles': detalles,
      };

  Map<String, dynamic> detalleJson({
    String? uuid,
    String nombre = 'Leche',
    num precio = 1000,
    String fecha = '2026-01-01T00:00:00.000',
  }) =>
      {
        'uuid': uuid,
        'nombre': nombre,
        'precio': precio,
        'fecha': fecha,
      };

  group('importFromJson — insert path', () {
    test('inserts a new compra with its detalles', () async {
      await db.importFromJson(jsonFor([
        compraJson(
          uuid: 'compra-1',
          titulo: 'Compra mensual',
          detalles: [detalleJson(uuid: 'det-1', nombre: 'Pan', precio: 500)],
        ),
      ]));

      final compras = await db.select(db.compras).get();
      final detalles = await db.select(db.compraDetalles).get();

      expect(compras, hasLength(1));
      expect(compras.single.titulo, 'Compra mensual');
      expect(compras.single.uuid, 'compra-1');
      expect(detalles, hasLength(1));
      expect(detalles.single.nombre, 'Pan');
      expect(detalles.single.precio, 500);
      expect(detalles.single.compra, compras.single.id);
    });

    test('generates a uuid when the incoming compra has none', () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: null, titulo: 'Sin uuid'),
      ]));

      final compra = (await db.select(db.compras).get()).single;
      expect(compra.uuid, isNotNull);
      expect(compra.uuid, isNotEmpty);
    });

    test('preserves archivado = true on import', () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: 'archived-1', archivado: true),
      ]));

      final compra = (await db.select(db.compras).get()).single;
      expect(compra.archivado, isTrue);
    });

    test('accepts a null presupuesto without crashing', () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: 'np-1', presupuesto: null),
      ]));

      final compra = (await db.select(db.compras).get()).single;
      expect(compra.presupuesto, isNull);
    });

    test('assigns increasing orden to multiple inserted compras', () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: 'a', fecha: '2026-01-01T00:00:00.000'),
        compraJson(uuid: 'b', fecha: '2026-01-02T00:00:00.000'),
      ]));

      final compras = await (db.select(db.compras)
            ..orderBy([(t) => OrderingTerm(expression: t.orden)]))
          .get();
      expect(compras.map((c) => c.orden), [0, 1]);
    });
  });

  group('importFromJson — dedup by uuid', () {
    test('re-importing the same uuid updates instead of duplicating',
        () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: 'dup-1', titulo: 'Original'),
      ]));

      await db.importFromJson(jsonFor([
        compraJson(uuid: 'dup-1', titulo: 'Editado'),
      ]));

      final compras = await db.select(db.compras).get();
      expect(compras, hasLength(1));
      expect(compras.single.titulo, 'Editado');
    });

    test('updating an existing compra replaces its detalles', () async {
      await db.importFromJson(jsonFor([
        compraJson(uuid: 'rep-1', detalles: [
          detalleJson(uuid: 'old', nombre: 'Viejo'),
        ]),
      ]));

      await db.importFromJson(jsonFor([
        compraJson(uuid: 'rep-1', detalles: [
          detalleJson(uuid: 'new', nombre: 'Nuevo'),
        ]),
      ]));

      final detalles = await db.select(db.compraDetalles).get();
      expect(detalles, hasLength(1));
      expect(detalles.single.nombre, 'Nuevo');
    });
  });

  group('export → import round-trip', () {
    test('a full export can be re-imported into a fresh database', () async {
      // Seed the source database directly.
      final compraId = await db.into(db.compras).insert(ComprasCompanion(
            uuid: const Value('rt-1'),
            titulo: const Value('Round trip'),
            fecha: const Value('2026-03-01T00:00:00.000'),
            archivado: const Value(true),
            presupuesto: const Value(2500.0),
          ));
      await db.into(db.compraDetalles).insert(CompraDetallesCompanion(
            uuid: const Value('rt-det-1'),
            nombre: const Value('Cafe'),
            precio: const Value(800.0),
            fecha: const Value('2026-03-01T00:00:00.000'),
            compra: Value(compraId),
          ));

      final exported = await db.exportToJson();

      // Import into a clean database.
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db2.close);
      await db2.importFromJson(exported);

      final compra = (await db2.select(db2.compras).get()).single;
      final detalle = (await db2.select(db2.compraDetalles).get()).single;

      expect(compra.uuid, 'rt-1');
      expect(compra.titulo, 'Round trip');
      expect(compra.archivado, isTrue);
      expect(compra.presupuesto, 2500.0);
      expect(detalle.uuid, 'rt-det-1');
      expect(detalle.nombre, 'Cafe');
      expect(detalle.precio, 800.0);
    });
  });
}

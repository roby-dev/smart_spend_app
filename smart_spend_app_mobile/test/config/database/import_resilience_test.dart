import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

/// Regression tests: importing a backup must be resilient. A malformed record
/// is skipped and reported by name, never aborting the whole restore.
///
/// These started life as bug-exposers (red). They are green once the import
/// pipeline tolerates bad records.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Map<String, dynamic> compraJson({
    String? uuid,
    String? titulo = 'Compra',
    String? fecha = '2026-01-01T00:00:00.000',
    List<Map<String, dynamic>> detalles = const [],
  }) =>
      {
        'uuid': uuid,
        'titulo': titulo,
        'fecha': fecha,
        'archivado': false,
        'presupuesto': null,
        'detalles': detalles,
      };

  test('a compra with a null fecha is skipped and reported by name', () async {
    final result = await db.importFromJson(jsonEncode([
      compraJson(uuid: 'null-fecha', titulo: 'Sin fecha', fecha: null),
    ]));

    expect(result.imported, 0);
    expect(result.failedTitulos, ['Sin fecha']);
    expect(result.failures.single.reason, contains('fecha'));
    expect(await db.select(db.compras).get(), isEmpty);
  });

  test('a detalle with a null fecha rolls back only its compra', () async {
    final result = await db.importFromJson(jsonEncode([
      compraJson(uuid: 'bad-detalle', titulo: 'Compra con item roto', detalles: [
        {'uuid': 'd1', 'nombre': 'Item', 'precio': 100, 'fecha': null},
      ]),
    ]));

    expect(result.imported, 0);
    expect(result.failedTitulos, ['Compra con item roto']);
    // No half-import: neither the compra nor its detalle leaked in.
    expect(await db.select(db.compras).get(), isEmpty);
    expect(await db.select(db.compraDetalles).get(), isEmpty);
  });

  test('one poison record does not discard the valid ones', () async {
    final result = await db.importFromJson(jsonEncode([
      compraJson(uuid: 'good-1', titulo: 'Buena'),
      compraJson(uuid: 'bad-1', titulo: 'Rota', fecha: null),
      compraJson(uuid: 'good-2', titulo: 'Tambien buena'),
    ]));

    expect(result.imported, 2);
    expect(result.hasFailures, isTrue);
    expect(result.failedTitulos, ['Rota']);

    final uuids = (await db.select(db.compras).get()).map((c) => c.uuid);
    expect(uuids, containsAll(['good-1', 'good-2']));
    expect(uuids, isNot(contains('bad-1')));
  });

  test('a fully valid import reports no failures', () async {
    final result = await db.importFromJson(jsonEncode([
      compraJson(uuid: 'ok-1', titulo: 'Perfecta'),
    ]));

    expect(result.imported, 1);
    expect(result.hasFailures, isFalse);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

void main() {
  test('in-memory AppDatabase opens and migrates', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final compras = await db.select(db.compras).get();
    expect(compras, isEmpty);
  });
}

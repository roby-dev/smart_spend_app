import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend_app/features/cloud_backup/screens/selective_restore_screen.dart';

/// Widget tests for the selective-restore checklist.
///
/// Selection must work for EVERY backup, including legacy snapshots whose
/// compras have no `uuid` (the field is optional on the backend).
void main() {
  Widget wrap(Map<String, dynamic> snapshot) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SelectiveRestoreScreen(snapshot: snapshot),
          ),
        ),
      );

  Map<String, dynamic> snapshotWith(List<Map<String, dynamic>> compras) => {
        'id': 'snap-1',
        'compras': compras,
      };

  List<CheckboxListTile> checkboxes(WidgetTester tester) =>
      tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile)).toList();

  testWidgets('select-all checks every row on a legacy backup without uuids',
      (tester) async {
    await tester.pumpWidget(wrap(snapshotWith([
      {'titulo': 'Compra A', 'detalles': <dynamic>[]},
      {'titulo': 'Compra B', 'detalles': <dynamic>[]},
    ])));

    // Precondition: nothing checked yet.
    expect(checkboxes(tester).every((c) => c.value == false), isTrue);

    await tester.tap(find.text('Seleccionar todo'));
    await tester.pump();

    expect(checkboxes(tester), hasLength(2));
    expect(checkboxes(tester).every((c) => c.value == true), isTrue);
  });

  testWidgets('select-all then deselect-all clears every row', (tester) async {
    await tester.pumpWidget(wrap(snapshotWith([
      {'titulo': 'Compra A', 'detalles': <dynamic>[]},
      {'titulo': 'Compra B', 'detalles': <dynamic>[]},
    ])));

    await tester.tap(find.text('Seleccionar todo'));
    await tester.pump();
    await tester.tap(find.text('Desmarcar todo'));
    await tester.pump();

    expect(checkboxes(tester).every((c) => c.value == false), isTrue);
  });

  testWidgets('an individual row can be toggled on a legacy backup',
      (tester) async {
    await tester.pumpWidget(wrap(snapshotWith([
      {'titulo': 'Compra A', 'detalles': <dynamic>[]},
      {'titulo': 'Compra B', 'detalles': <dynamic>[]},
    ])));

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();

    final boxes = checkboxes(tester);
    expect(boxes[0].value, isTrue);
    expect(boxes[1].value, isFalse);
  });

  testWidgets('selection also works when compras DO have uuids',
      (tester) async {
    await tester.pumpWidget(wrap(snapshotWith([
      {'uuid': 'u-1', 'titulo': 'Compra A', 'detalles': <dynamic>[]},
      {'uuid': 'u-2', 'titulo': 'Compra B', 'detalles': <dynamic>[]},
    ])));

    await tester.tap(find.text('Seleccionar todo'));
    await tester.pump();

    expect(checkboxes(tester).every((c) => c.value == true), isTrue);
  });
}

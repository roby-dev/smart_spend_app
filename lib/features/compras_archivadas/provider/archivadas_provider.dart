import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/main.dart';
import 'package:smart_spend_app/models/compra_model.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';

final archivadasProvider =
    NotifierProvider<ArchivadasNotifier, ArchivadasState>(
        () => ArchivadasNotifier());

class ArchivadasNotifier extends Notifier<ArchivadasState> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  ArchivadasState build() {
    return const ArchivadasState();
  }

  Future<void> loadArchivadas() async {
    final archivadas = await (_db.select(_db.compras)
          ..where((tbl) => tbl.archivado.equals(true)))
        .get();

    final comprasConDetalles = await Future.wait(archivadas.map((compra) async {
      final detalles = await (_db.select(_db.compraDetalles)
            ..where((tbl) => tbl.compra.equals(compra.id)))
          .get();

      return CompraModel(
        id: compra.id,
        titulo: compra.titulo,
        fecha: DateTime.parse(compra.fecha),
        archivado: compra.archivado,
        detalles: detalles.map((detalle) {
          return CompraDetalleModel(
            id: detalle.id,
            nombre: detalle.nombre,
            precio: detalle.precio,
            compraId: detalle.compra,
            fecha: DateTime.parse(detalle.fecha),
          );
        }).toList(),
      );
    }).toList());

    state = state.copyWith(compras: comprasConDetalles);
  }

  Future<void> restoreSelected(List<int> selectedIds) async {
    for (final id in selectedIds) {
      await (_db.update(_db.compras)..where((tbl) => tbl.id.equals(id)))
          .write(const ComprasCompanion(archivado: Value(false)));
    }

    await loadArchivadas();
    ref.read(homeProvider.notifier).toggleComprasSelection();
  }
}

class ArchivadasState {
  final List<CompraModel> compras;

  const ArchivadasState({
    this.compras = const [],
  });

  ArchivadasState copyWith({
    List<CompraModel>? compras,
  }) {
    return ArchivadasState(
      compras: compras ?? this.compras,
    );
  }
}

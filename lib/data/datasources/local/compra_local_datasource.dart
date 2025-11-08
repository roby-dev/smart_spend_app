import 'package:drift/drift.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

abstract class CompraLocalDataSource {
  Future<List<Compra>> getAllCompras();
  Future<List<Compra>> getActiveCompras();
  Future<List<Compra>> getArchivedCompras();
  Future<Compra?> getCompraById(int id);
  Future<int> insertCompra(ComprasCompanion compra);
  Future<bool> updateCompra(ComprasCompanion compra);
  Future<bool> deleteCompra(int id);
  Future<bool> updateArchivedStatus(int id, bool archived);
  Future<bool> updateComprasOrden(List<Map<String, int>> ordenList);
  Future<List<CompraWithDetails>> getComprasWithDetails(
      {bool includeArchived = false});
}

class CompraLocalDataSourceImpl implements CompraLocalDataSource {
  final AppDatabase _database;

  CompraLocalDataSourceImpl(this._database);

  @override
  Future<List<Compra>> getAllCompras() async {
    return await _database.select(_database.compras).get();
  }

  @override
  Future<List<Compra>> getActiveCompras() async {
    return await (_database.select(_database.compras)
          ..where((tbl) => tbl.archivado.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
        .get();
  }

  @override
  Future<List<Compra>> getArchivedCompras() async {
    return await (_database.select(_database.compras)
          ..where((tbl) => tbl.archivado.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
  }

  @override
  Future<Compra?> getCompraById(int id) async {
    return await (_database.select(_database.compras)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertCompra(ComprasCompanion compra) async {
    return await _database.into(_database.compras).insert(compra);
  }

  @override
  Future<bool> updateCompra(ComprasCompanion compra) async {
    try {
      await _database.update(_database.compras).replace(compra);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteCompra(int id) async {
    try {
      final deleted = await (_database.delete(_database.compras)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return deleted > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateArchivedStatus(int id, bool archived) async {
    try {
      final updated = await (_database.update(_database.compras)
            ..where((tbl) => tbl.id.equals(id)))
          .write(ComprasCompanion(archivado: Value(archived)));
      return updated > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateComprasOrden(List<Map<String, int>> ordenList) async {
    try {
      await _database.transaction(() async {
        for (var item in ordenList) {
          final id = item['id']!;
          final orden = item['orden']!;
          await (_database.update(_database.compras)
                ..where((tbl) => tbl.id.equals(id)))
              .write(ComprasCompanion(orden: Value(orden)));
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CompraWithDetails>> getComprasWithDetails({
    bool includeArchived = false,
  }) async {
    final query = _database.select(_database.compras).join([
      leftOuterJoin(
        _database.compraDetalles,
        _database.compraDetalles.compra.equalsExp(_database.compras.id),
      )
    ]);

    if (!includeArchived) {
      query.where(_database.compras.archivado.equals(false));
    }

    query.orderBy([OrderingTerm.asc(_database.compras.orden)]);

    final rows = await query.get();

    // Agrupar resultados por compra
    final Map<int, CompraWithDetails> comprasMap = {};

    for (final row in rows) {
      final compra = row.readTable(_database.compras);
      final detalle = row.readTableOrNull(_database.compraDetalles);

      if (!comprasMap.containsKey(compra.id)) {
        comprasMap[compra.id] = CompraWithDetails(
          compra: compra,
          detalles: [],
        );
      }

      if (detalle != null) {
        comprasMap[compra.id]!.detalles.add(detalle);
      }
    }

    return comprasMap.values.toList();
  }
}

/// Clase auxiliar para agrupar compra con sus detalles
class CompraWithDetails {
  final Compra compra;
  final List<CompraDetalle> detalles;

  CompraWithDetails({
    required this.compra,
    required this.detalles,
  });
}

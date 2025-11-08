import 'package:drift/drift.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';

abstract class CompraDetalleLocalDataSource {
  Future<List<CompraDetalle>> getDetallesByCompraId(int compraId);
  Future<CompraDetalle?> getDetalleById(int id);
  Future<int> insertDetalle(CompraDetallesCompanion detalle);
  Future<bool> updateDetalle(CompraDetallesCompanion detalle);
  Future<bool> deleteDetalle(int id);
  Future<bool> deleteDetallesByCompraId(int compraId);
  Future<double> getTotalByCompraId(int compraId);
}

class CompraDetalleLocalDataSourceImpl implements CompraDetalleLocalDataSource {
  final AppDatabase _database;

  CompraDetalleLocalDataSourceImpl(this._database);

  @override
  Future<List<CompraDetalle>> getDetallesByCompraId(int compraId) async {
    return await (_database.select(_database.compraDetalles)
          ..where((tbl) => tbl.compra.equals(compraId))
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
  }

  @override
  Future<CompraDetalle?> getDetalleById(int id) async {
    return await (_database.select(_database.compraDetalles)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertDetalle(CompraDetallesCompanion detalle) async {
    return await _database.into(_database.compraDetalles).insert(detalle);
  }

  @override
  Future<bool> updateDetalle(CompraDetallesCompanion detalle) async {
    try {
      await _database.update(_database.compraDetalles).replace(detalle);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteDetalle(int id) async {
    try {
      final deleted = await (_database.delete(_database.compraDetalles)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
      return deleted > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteDetallesByCompraId(int compraId) async {
    try {
      await (_database.delete(_database.compraDetalles)
            ..where((tbl) => tbl.compra.equals(compraId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<double> getTotalByCompraId(int compraId) async {
    final query = _database.selectOnly(_database.compraDetalles)
      ..where(_database.compraDetalles.compra.equals(compraId))
      ..addColumns([_database.compraDetalles.precio.sum()]);

    final result = await query.getSingleOrNull();
    return result?.read(_database.compraDetalles.precio.sum()) ?? 0.0;
  }
}

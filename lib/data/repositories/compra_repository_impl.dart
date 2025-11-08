import 'package:drift/drift.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/data/datasources/local/compra_local_datasource.dart';
import 'package:smart_spend_app/data/datasources/local/compra_detalle_local_datasource.dart';
import 'package:smart_spend_app/domain/models/compra_model.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';
import 'package:smart_spend_app/domain/repositories/compra_repository.dart';

class CompraRepositoryImpl implements CompraRepository {
  final CompraLocalDataSource _compraDataSource;
  final CompraDetalleLocalDataSource _detalleDataSource;
  final AppDatabase _database;

  CompraRepositoryImpl({
    required CompraLocalDataSource compraDataSource,
    required CompraDetalleLocalDataSource detalleDataSource,
    required AppDatabase database,
  })  : _compraDataSource = compraDataSource,
        _detalleDataSource = detalleDataSource,
        _database = database;

  // ========== CONVERSIONES ENTITY -> MODEL ==========

  CompraModel _entityToModel(Compra entity,
      {List<CompraDetalleModel>? detalles}) {
    return CompraModel(
      id: entity.id,
      titulo: entity.titulo,
      fecha: DateTime.parse(entity.fecha),
      archivado: entity.archivado,
      presupuesto: entity.presupuesto,
      orden: entity.orden,
      detalles: detalles ?? [],
    );
  }

  CompraDetalleModel _detalleEntityToModel(CompraDetalle entity) {
    return CompraDetalleModel(
      id: entity.id,
      nombre: entity.nombre,
      precio: entity.precio,
      compraId: entity.compra,
      fecha: DateTime.parse(entity.fecha),
    );
  }

  ComprasCompanion _modelToCompanion(CompraModel model) {
    return ComprasCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      titulo: Value(model.titulo),
      fecha: Value(model.fecha.toIso8601String()),
      archivado: Value(model.archivado),
      presupuesto: Value(model.presupuesto),
      orden: Value(model.orden),
    );
  }

  CompraDetallesCompanion _detalleModelToCompanion(CompraDetalleModel model) {
    return CompraDetallesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      nombre: Value(model.nombre),
      precio: Value(model.precio),
      compra: Value(model.compraId),
      fecha: Value(model.fecha.toIso8601String()),
    );
  }

  // ========== IMPLEMENTACIÓN DE MÉTODOS ==========

  @override
  Future<List<CompraModel>> getAllCompras() async {
    final entities = await _compraDataSource.getAllCompras();
    return entities.map((e) => _entityToModel(e)).toList();
  }

  @override
  Future<List<CompraModel>> getActiveCompras() async {
    final entities = await _compraDataSource.getActiveCompras();
    return entities.map((e) => _entityToModel(e)).toList();
  }

  @override
  Future<List<CompraModel>> getArchivedCompras() async {
    final entities = await _compraDataSource.getArchivedCompras();
    return entities.map((e) => _entityToModel(e)).toList();
  }

  @override
  Future<CompraModel?> getCompraById(int id) async {
    final entity = await _compraDataSource.getCompraById(id);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  @override
  Future<CompraModel> createCompra(CompraModel compra) async {
    final companion = _modelToCompanion(compra);
    final id = await _compraDataSource.insertCompra(companion);
    return compra.copyWith(id: id);
  }

  @override
  Future<bool> updateCompra(CompraModel compra) async {
    final companion = _modelToCompanion(compra);
    return await _compraDataSource.updateCompra(companion);
  }

  @override
  Future<bool> deleteCompra(int id) async {
    // Primero eliminar detalles
    await _detalleDataSource.deleteDetallesByCompraId(id);
    // Luego eliminar compra
    return await _compraDataSource.deleteCompra(id);
  }

  @override
  Future<bool> archiveCompra(int id) async {
    return await _compraDataSource.updateArchivedStatus(id, true);
  }

  @override
  Future<bool> unarchiveCompra(int id) async {
    return await _compraDataSource.updateArchivedStatus(id, false);
  }

  @override
  Future<bool> updateComprasOrder(List<CompraModel> compras) async {
    final ordenList = compras
        .asMap()
        .entries
        .map((entry) => {
              'id': entry.value.id!,
              'orden': entry.key,
            })
        .toList();
    return await _compraDataSource.updateComprasOrden(ordenList);
  }

  @override
  Future<List<CompraModel>> getComprasWithDetails(
      {bool includeArchived = false}) async {
    final comprasWithDetails = await _compraDataSource.getComprasWithDetails(
      includeArchived: includeArchived,
    );

    return comprasWithDetails.map((cwd) {
      final detalles = cwd.detalles.map(_detalleEntityToModel).toList();
      return _entityToModel(cwd.compra, detalles: detalles);
    }).toList();
  }

  @override
  Future<CompraModel?> getCompraWithDetailsById(int id) async {
    final compra = await _compraDataSource.getCompraById(id);
    if (compra == null) return null;

    final detallesEntities = await _detalleDataSource.getDetallesByCompraId(id);
    final detalles = detallesEntities.map(_detalleEntityToModel).toList();

    return _entityToModel(compra, detalles: detalles);
  }

  @override
  Future<List<CompraDetalleModel>> getDetallesByCompraId(int compraId) async {
    final entities = await _detalleDataSource.getDetallesByCompraId(compraId);
    return entities.map(_detalleEntityToModel).toList();
  }

  @override
  Future<CompraDetalleModel> addDetalle(CompraDetalleModel detalle) async {
    final companion = _detalleModelToCompanion(detalle);
    final id = await _detalleDataSource.insertDetalle(companion);
    return detalle.copyWith(id: id);
  }

  @override
  Future<bool> updateDetalle(CompraDetalleModel detalle) async {
    final companion = _detalleModelToCompanion(detalle);
    return await _detalleDataSource.updateDetalle(companion);
  }

  @override
  Future<bool> deleteDetalle(int id) async {
    return await _detalleDataSource.deleteDetalle(id);
  }

  @override
  Future<double> getTotalGastado(int compraId) async {
    return await _detalleDataSource.getTotalByCompraId(compraId);
  }

  @override
  Future<String> exportToJson() async {
    return await _database.exportToJson();
  }

  @override
  Future<bool> importFromJson(String jsonString) async {
    try {
      await _database.importFromJson(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}

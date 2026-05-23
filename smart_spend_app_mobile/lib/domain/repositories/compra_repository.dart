import 'package:smart_spend_app/domain/models/compra_model.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';

abstract class CompraRepository {
  // Operaciones de Compra
  Future<List<CompraModel>> getAllCompras();
  Future<List<CompraModel>> getActiveCompras();
  Future<List<CompraModel>> getArchivedCompras();
  Future<CompraModel?> getCompraById(int id);
  Future<CompraModel> createCompra(CompraModel compra);
  Future<bool> updateCompra(CompraModel compra);
  Future<bool> deleteCompra(int id);
  Future<bool> archiveCompra(int id);
  Future<bool> unarchiveCompra(int id);
  Future<bool> updateComprasOrder(List<CompraModel> compras);

  // Operaciones de Compra con Detalles
  Future<List<CompraModel>> getComprasWithDetails(
      {bool includeArchived = false});
  Future<CompraModel?> getCompraWithDetailsById(int id);

  // Operaciones de Detalle
  Future<List<CompraDetalleModel>> getDetallesByCompraId(int compraId);
  Future<CompraDetalleModel> addDetalle(CompraDetalleModel detalle);
  Future<bool> updateDetalle(CompraDetalleModel detalle);
  Future<bool> deleteDetalle(int id);
  Future<double> getTotalGastado(int compraId);

  // Operaciones de Exportación/Importación
  Future<String> exportToJson();
  Future<bool> importFromJson(String jsonString);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/data/datasources/local/compra_local_datasource.dart';
import 'package:smart_spend_app/data/datasources/local/compra_detalle_local_datasource.dart';
import 'package:smart_spend_app/data/repositories/compra_repository_impl.dart';
import 'package:smart_spend_app/domain/repositories/compra_repository.dart';
import 'package:smart_spend_app/main.dart';

// Provider del DataSource de Compra
final compraLocalDataSourceProvider = Provider<CompraLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CompraLocalDataSourceImpl(database);
});

// Provider del DataSource de Detalle
final compraDetalleLocalDataSourceProvider =
    Provider<CompraDetalleLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CompraDetalleLocalDataSourceImpl(database);
});

// Provider del Repository (PRINCIPAL)
final compraRepositoryProvider = Provider<CompraRepository>((ref) {
  final compraDataSource = ref.watch(compraLocalDataSourceProvider);
  final detalleDataSource = ref.watch(compraDetalleLocalDataSourceProvider);
  final database = ref.watch(databaseProvider);

  return CompraRepositoryImpl(
    compraDataSource: compraDataSource,
    detalleDataSource: detalleDataSource,
    database: database,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';

final compraDetalleProvider =
    StateNotifierProvider<CompraDetalleNotifier, CompraDetalleState>(
  (ref) => CompraDetalleNotifier(ref),
);

class CompraDetalleNotifier extends StateNotifier<CompraDetalleState> {
  CompraDetalleNotifier(this.ref) : super(CompraDetalleState());

  final StateNotifierProviderRef ref;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<CompraDetalle>> loadCompraDetalles(int compraId) async {
    // Carga los detalles de la compra desde la base de datos
    final detalles = await _dbHelper.getCompraDetalles(compraId);

    // Actualiza el estado con los detalles cargados
    state = state.copyWith(
      detalles: detalles,
    );

    return detalles;
  }
}

class CompraDetalleState {
  CompraDetalleState({this.detalles = const []});

  final List<CompraDetalle> detalles;

  CompraDetalleState copyWith({List<CompraDetalle>? detalles}) {
    return CompraDetalleState(
      detalles: detalles ?? this.detalles,
    );
  }
}

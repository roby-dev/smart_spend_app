import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/dialog_add_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
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
    final detalles = await _dbHelper.getCompraDetalles(compraId);
    state = state.copyWith(detalles: detalles, compraId: compraId);
    return detalles;
  }

  Future<void> addDetalle(CompraDetalle detalle) async {
    await _dbHelper.insertCompraDetalle(detalle);
    await loadCompraDetalles(detalle.compraId);
  }

  Future<void> updateDetalle(int index, CompraDetalle updatedDetalle) async {
    await _dbHelper.insertCompraDetalle(
        updatedDetalle); // Usa insert para actualizar o reemplazar
    state.detalles[index] = updatedDetalle;
    state = state.copyWith(detalles: List.from(state.detalles));
  }

  Future<void> showAddDetalleDialog({required BuildContext context}) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController precioController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddDetalleDialog(
          nombreController: nombreController,
          precioController: precioController,
          compraId: state.compraId,
          onPressed: () {
            final nombre = nombreController.text.trim();
            final precio = double.tryParse(precioController.text) ?? 0.0;

            if (nombre.isNotEmpty && precio > 0) {
              ref.read(compraDetalleProvider.notifier).addDetalle(
                    CompraDetalle(
                      nombre: nombre,
                      precio: precio,
                      compraId: state.compraId,
                    ),
                  );
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void saveTitle({required String newTitle}) {
    final compra = ref.read(homeProvider).selectedCompra;

    if (compra != null && newTitle.isNotEmpty && newTitle != compra.titulo) {
      final updatedCompra = compra.copyWith(titulo: newTitle);
      ref.read(homeProvider.notifier).saveCompra(updatedCompra, []);
    }
  }
}

class CompraDetalleState {
  final List<CompraDetalle> detalles;
  final int compraId;

  CompraDetalleState({this.detalles = const [], this.compraId = 0});

  CompraDetalleState copyWith({List<CompraDetalle>? detalles, int? compraId}) {
    return CompraDetalleState(
        detalles: detalles ?? this.detalles,
        compraId: compraId ?? this.compraId);
  }
}

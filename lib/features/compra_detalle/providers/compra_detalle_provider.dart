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

  void initDatos() {
    state = state.copyWith(isEditing: false, isDetallesSelected: false);
  }

  Future<List<CompraDetalle>> loadCompraDetalles(int compraId) async {
    final detalles = await _dbHelper.getCompraDetalles(compraId);
    state = state.copyWith(detalles: detalles, compraId: compraId);
    return detalles;
  }

  Future<void> addDetalle(CompraDetalle detalle) async {
    await _dbHelper.insertCompraDetalle(detalle);
    await loadCompraDetalles(detalle.compraId);
    await ref.read(homeProvider.notifier).loadCompras();
  }

  Future<void> updateDetalle(int index, CompraDetalle updatedDetalle) async {
    await _dbHelper.insertCompraDetalle(updatedDetalle);
    state.detalles[index] = updatedDetalle;
    state = state.copyWith(detalles: List.from(state.detalles));
    await ref.read(homeProvider.notifier).loadCompras();
  }

  Future<void> deleteSelectedDetalles() async {
    for (var index in state.selectedDetalles) {
      final detalle = state.detalles[index];
      await _dbHelper.deleteCompraDetalle(detalle.id!);
    }
    toggleDetallesSelection();
    await ref.read(homeProvider.notifier).loadCompras();
    await loadCompraDetalles(state.compraId);
  }

  Future<void> deleteCurrentCompraDetalle(int compraDetalleId) async {
    await _dbHelper.deleteCompraDetalle(compraDetalleId);
    await loadCompraDetalles(state.compraId);
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

            if (nombre.isNotEmpty && precio >= 0) {
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

  void toggleDetallesSelection() {
    state = state.copyWith(isDetallesSelected: !state.isDetallesSelected);
    if (!state.isDetallesSelected) {
      deselectAllDetalles();
    }
  }

  void toggleDetalleSelection(int index) {
    final selectedDetalles = List<int>.from(state.selectedDetalles);
    if (selectedDetalles.contains(index)) {
      selectedDetalles.remove(index);
    } else {
      selectedDetalles.add(index);
    }
    state = state.copyWith(selectedDetalles: selectedDetalles);
  }

  void deselectAllDetalles() {
    state = state.copyWith(
      isDetallesSelected: false,
      selectedDetalles: [],
    );
  }

  String tituloScreen() {
    if (!state.isDetallesSelected) return ' Detalles de la compra';
    if (state.selectedDetalles.isEmpty) return ' Seleccione elementos';
    if (state.selectedDetalles.length > 1) {
      return ' ${state.selectedDetalles.length} elementos seleccionados';
    } else {
      return ' 1 elemento seleccionado';
    }
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }
}

class CompraDetalleState {
  final List<CompraDetalle> detalles;
  final int compraId;
  final bool isDetallesSelected;
  final List<int> selectedDetalles;
  final bool isEditing;

  CompraDetalleState({
    this.detalles = const [],
    this.compraId = 0,
    this.isDetallesSelected = false,
    this.selectedDetalles = const [],
    this.isEditing = false,
  });

  CompraDetalleState copyWith({
    List<CompraDetalle>? detalles,
    int? compraId,
    bool? isDetallesSelected,
    List<int>? selectedDetalles,
    bool? isEditing,
  }) {
    return CompraDetalleState(
        detalles: detalles ?? this.detalles,
        compraId: compraId ?? this.compraId,
        isDetallesSelected: isDetallesSelected ?? this.isDetallesSelected,
        selectedDetalles: selectedDetalles ?? this.selectedDetalles,
        isEditing: isEditing ?? this.isEditing);
  }
}

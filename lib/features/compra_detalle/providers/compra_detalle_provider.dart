import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/dialog_add_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';
import 'package:smart_spend_app/models/compra_model.dart';

final compraDetalleProvider =
    StateNotifierProvider<CompraDetalleNotifier, CompraDetalleState>(
  (ref) => CompraDetalleNotifier(ref),
);

class CompraDetalleNotifier extends StateNotifier<CompraDetalleState> {
  CompraDetalleNotifier(this.ref) : super(CompraDetalleState());

  final StateNotifierProviderRef ref;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  GlobalKey? dialogAgregarDetalleKey;

  Future<void> initDatos({required bool withLoad}) async {
    state = state.copyWith(
        isEditing: false,
        isDetallesSelected: false,
        detalles: [],
        isLoading: true,
        compra: ref.read(homeProvider).selectedCompra);

    if (withLoad) {
      await loadCompraDetalles(ref.read(homeProvider).selectedCompraId!);
    }
  }

  void initLoading() {
    state = state.copyWith(isLoading: true);
  }

  Future<List<CompraDetalle>> loadCompraDetalles(int compraId) async {
    final detalles = await _dbHelper.getCompraDetalles(compraId);
    state = state.copyWith(
        detalles: detalles, compraId: compraId, isLoading: false);
    return detalles;
  }

  Future<void> addDetalle(CompraDetalle detalle) async {
    await _dbHelper.insertCompraDetalle(detalle);
    await loadCompraDetalles(detalle.compraId);
    await ref.read(homeProvider.notifier).loadCompras();
  }

  Future<void> updateDetalle(int index, CompraDetalle updatedDetalle) async {
    final newDetalles = List<CompraDetalle>.from(state.detalles);
    newDetalles[index] = updatedDetalle;
    state = state.copyWith(detalles: List.from(newDetalles));
    await _dbHelper.insertCompraDetalle(updatedDetalle);
    await ref.read(homeProvider.notifier).loadCompras();
    //initDatos();
  }

  Future<void> deleteSelectedDetalles() async {
    for (var index in state.selectedDetalles) {
      final detalle = state.detalles[index];
      await _dbHelper.deleteCompraDetalle(detalle.id!);
    }
    toggleDetallesSelection();
    ref.read(homeProvider.notifier).loadCompras();
    await loadCompraDetalles(state.compraId);
  }

  Future<void> deleteCurrentCompraDetalle(int compraDetalleId) async {
    await _dbHelper.deleteCompraDetalle(compraDetalleId);
    await loadCompraDetalles(state.compraId);
  }

  Future<void> showAddDetalleDialog({required BuildContext context}) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController precioController =
        TextEditingController(text: '0.00');
    late FocusNode nombreFocusNode = FocusNode();
    late FocusNode precioFocusNode = FocusNode();

    precioFocusNode.addListener(() {
      if (precioFocusNode.hasFocus) {
        if (precioController.text == '0.00' || precioController.text == '0') {
          precioController.clear();
        }
      }
    });

    dialogAgregarDetalleKey = GlobalKey();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddDetalleDialog(
          key: dialogAgregarDetalleKey,
          nombreController: nombreController,
          nombreFocusNode: nombreFocusNode,
          preciFocusNode: precioFocusNode,
          precioController: precioController,
          compraId: state.compraId,
          onPressed: () async {
            final nombre = nombreController.text.trim();
            final precio = double.tryParse(precioController.text) ?? 0.0;

            if (nombre.isNotEmpty && precio >= 0) {
              ref.read(compraDetalleProvider.notifier).addDetalle(
                    CompraDetalle(
                        nombre: nombre,
                        precio: precio,
                        compraId: state.compraId,
                        fecha: DateTime.now()),
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
  final Compra? compra;
  final int compraId;
  final bool isDetallesSelected;
  final List<int> selectedDetalles;
  final bool isEditing;
  final bool isLoading;

  CompraDetalleState(
      {this.detalles = const [],
      this.compraId = 0,
      this.isDetallesSelected = false,
      this.selectedDetalles = const [],
      this.isEditing = false,
      this.isLoading = true,
      this.compra});

  CompraDetalleState copyWith({
    List<CompraDetalle>? detalles,
    int? compraId,
    bool? isDetallesSelected,
    List<int>? selectedDetalles,
    bool? isEditing,
    bool? isLoading,
    Compra? compra,
  }) {
    return CompraDetalleState(
        detalles: detalles ?? this.detalles,
        compraId: compraId ?? this.compraId,
        isDetallesSelected: isDetallesSelected ?? this.isDetallesSelected,
        selectedDetalles: selectedDetalles ?? this.selectedDetalles,
        isEditing: isEditing ?? this.isEditing,
        isLoading: isLoading ?? this.isLoading,
        compra: compra ?? this.compra);
  }
}

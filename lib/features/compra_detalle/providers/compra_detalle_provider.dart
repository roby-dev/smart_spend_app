import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/data/repositories/compra_repository_provider.dart';
import 'package:smart_spend_app/domain/repositories/compra_repository.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/dialog_add_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';
import 'package:smart_spend_app/domain/models/compra_model.dart';

final compraDetalleProvider =
    StateNotifierProvider<CompraDetalleNotifier, CompraDetalleState>(
  (ref) {
    final repository = ref.watch(compraRepositoryProvider);
    final compra = ref.watch(homeProvider).selectedCompra;
    return CompraDetalleNotifier(repository, compra!);
  },
);

class CompraDetalleNotifier extends StateNotifier<CompraDetalleState> {
  final CompraRepository _repository;
  final CompraModel _compra;

  CompraDetalleNotifier(this._repository, this._compra)
      : super(CompraDetalleState());
  GlobalKey? dialogAgregarDetalleKey;

  Future<void> initDatos() async {
    state = state.copyWith(
      isEditing: false,
      isDetallesSelected: false,
      detalles: _compra.detalles,
      isLoading: false,
      compra: _compra,
      compraId: _compra.id,
    );
  }

  void initLoading() {
    state = state.copyWith(isLoading: true);
  }

  Future<List<CompraDetalleModel>> loadCompraDetalles(int compraId) async {
    final detalles = await _repository.getDetallesByCompraId(compraId);

    state = state.copyWith(
      detalles: detalles,
      compraId: compraId,
      isLoading: false,
    );
    return detalles;
  }

  Future<void> addDetalle(CompraDetalleModel detalle) async {
    final newDetalle = await _repository.addDetalle(detalle);
    final updatedDetalles = [...state.detalles, newDetalle];

    state = state.copyWith(detalles: updatedDetalles);
  }

  Future<void> updateDetalle(
      int index, CompraDetalleModel updatedDetalle) async {
    final updated = await _repository.updateDetalle(updatedDetalle);

    if (updated) {
      await loadCompraDetalles(updatedDetalle.compraId);
    }
  }

  Future<void> deleteCurrentCompraDetalle(int compraDetalleId) async {
    final updated = await _repository.deleteDetalle(compraDetalleId);

    if (updated) {
      await loadCompraDetalles(state.compraId);
    }
  }

  Future<void> showAddDetalleDialog({required BuildContext context}) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController precioController =
        TextEditingController(text: '0.00');
    final FocusNode nombreFocusNode = FocusNode();
    final FocusNode precioFocusNode = FocusNode();

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
              final detalleCompra = CompraDetalleModel(
                nombre: nombre,
                precio: precio,
                compraId: state.compraId,
                fecha: DateTime.now(),
              );
              await addDetalle(detalleCompra);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> saveTitle({required String newTitle}) async {
    if (newTitle.isNotEmpty && newTitle != _compra.titulo) {
      final updatedCompra = state.compra!.copyWith(titulo: newTitle);
      await _repository.updateCompra(updatedCompra);
      state = state.copyWith(compra: updatedCompra);
    }
  }

  void deselectAllDetalles() {
    state = state.copyWith(
      isDetallesSelected: false,
      selectedDetalles: [],
    );
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  Future<void> savePresupuesto(double? nuevoPresupuesto) async {
    final updatedCompra = state.compra!.copyWith(presupuesto: nuevoPresupuesto);
    await _repository.updateCompra(updatedCompra);
    state = state.copyWith(compra: updatedCompra);
  }
}

class CompraDetalleState {
  final List<CompraDetalleModel> detalles;
  final CompraModel? compra;
  final int compraId;
  final bool isEditing;
  final bool isLoading;

  CompraDetalleState(
      {this.detalles = const [],
      this.compraId = 0,
      this.isEditing = false,
      this.isLoading = true,
      this.compra});

  CompraDetalleState copyWith({
    List<CompraDetalleModel>? detalles,
    int? compraId,
    bool? isDetallesSelected,
    List<int>? selectedDetalles,
    bool? isEditing,
    bool? isLoading,
    CompraModel? compra,
  }) {
    return CompraDetalleState(
        detalles: detalles ?? this.detalles,
        compraId: compraId ?? this.compraId,
        isEditing: isEditing ?? this.isEditing,
        isLoading: isLoading ?? this.isLoading,
        compra: compra ?? this.compra);
  }
}

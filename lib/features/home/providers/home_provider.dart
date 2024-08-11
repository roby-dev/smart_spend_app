import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/database/database_helper.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/models/compra_model.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_agregar_editar_compra.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_confirmar_eliminar.dart';

final homeProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier(ref));

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(HomeState());

  final StateNotifierProviderRef ref;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GoRouter router = appRouter;

  Future<void> saveCompra(Compra compra, List<CompraDetalle> detalles) async {
    final compraId = await _dbHelper.insertCompra(compra);

    for (var detalle in detalles) {
      await _dbHelper.insertCompraDetalle(detalle.copyWith(compraId: compraId));
    }

    await loadCompras();
  }

  Future<void> loadCompras() async {
    final compras = await _dbHelper.getCompras();

    state = state.copyWith(
      compras: compras,
    );
  }

  void selectCompra(Compra compra) {
    state = state.copyWith(
        selectedCompraId: compra.id!,
        isCompraSelected: true,
        selectedCompra: compra);
  }

  Future<void> deleteCompra(int compraId) async {
    await _dbHelper.deleteCompra(compraId);
    await loadCompras();
  }

  void deselectCompra() {
    state = state.copyWith(isCompraSelected: false);
  }

  void deselectAllCompras() {
    state = state.copyWith(
      isCompraSelected: false,
      selectedCompras: [],
    );
  }

  void toggleCompraSelection(int compraId) {
    final selectedCompras = List<int>.from(state.selectedCompras);
    if (selectedCompras.contains(compraId)) {
      selectedCompras.remove(compraId);
    } else {
      selectedCompras.add(compraId);
    }
    state = state.copyWith(selectedCompras: selectedCompras);
  }

  Future<void> deleteSelectedCompras() async {
    final selectedCompras = List<int>.from(state.selectedCompras);
    for (var compraId in selectedCompras) {
      await _dbHelper.deleteCompra(compraId);
    }
    toggleComprasSelection();
    await loadCompras();
  }

  void toggleComprasSelection() {
    state = state.copyWith(isComprasSelected: !state.isComprasSelected);
    if (!state.isComprasSelected) {
      deselectAllCompras();
    }
  }

  Future<void> showAddEditCompraDialog(
      {required BuildContext context, Compra? compra}) async {
    final TextEditingController titleController =
        TextEditingController(text: compra?.titulo ?? '');
    final FocusNode focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    final homeNotifier = ref.read(homeProvider.notifier);

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AddEditComprasDialog(
            title: compra != null ? 'Editar compra' : 'Nueva compra',
            onPressed: () {
              _handleSaveCompra(
                  context, titleController.text.trim(), homeNotifier,
                  compra: compra);
            },
            titleController: titleController,
            focusNode: focusNode,
          );
        });
  }

  void _handleSaveCompra(BuildContext context, title, HomeNotifier homeNotifier,
      {Compra? compra}) {
    if (title.isNotEmpty) {
      if (compra != null) {
        final updatedCompra = compra.copyWith(titulo: title);
        homeNotifier
            .saveCompra(updatedCompra, []); // Guarda la compra actualizada
      } else {
        final compra = Compra(
          titulo: title,
          fecha: DateTime.now(),
        );
        homeNotifier.saveCompra(compra, []);
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> showDeleteConfirmationDialog(
      {required BuildContext context, int? compraId}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(onPressed: () {
          if (compraId != null) {
            deleteCompra(compraId);
          } else {
            deleteSelectedCompras();
          }
          Navigator.of(context).pop();
        });
      },
    );
  }

  String tituloScreen() {
    if (!state.isComprasSelected) return ' Mis compras';
    if (state.selectedCompras.isEmpty) return ' Seleccione elementos';
    if (state.selectedCompras.length > 1) {
      return ' ${state.selectedCompras.length} elementos seleccionados';
    } else {
      return ' 1 elemento seleccionado';
    }
  }

  void goDetalleCompra({required Compra compra}) {
    selectCompra(compra);
    ref.read(compraDetalleProvider.notifier).loadCompraDetalles(compra.id!);
  }
}

class HomeState {
  final List<Compra> compras;
  final int selectedCompraId;
  final bool isComprasSelected;
  final List<int> selectedCompras;
  Compra? selectedCompra;

  HomeState(
      {this.compras = const [],
      this.selectedCompraId = -1,
      this.isComprasSelected = false,
      this.selectedCompras = const [],
      this.selectedCompra});

  HomeState copyWith(
      {List<Compra>? compras,
      int? selectedCompraId,
      bool? isCompraSelected,
      bool? isComprasSelected,
      List<int>? selectedCompras,
      Compra? selectedCompra}) {
    return HomeState(
      compras: compras ?? this.compras,
      selectedCompraId: selectedCompraId ?? this.selectedCompraId,
      isComprasSelected: isComprasSelected ?? this.isComprasSelected,
      selectedCompras: selectedCompras ?? this.selectedCompras,
      selectedCompra: selectedCompra ?? this.selectedCompra,
    );
  }
}

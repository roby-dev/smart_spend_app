import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/data/repositories/compra_repository_provider.dart';
import 'package:smart_spend_app/domain/repositories/compra_repository.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/main.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_agregar_editar_compra.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_confirmar_eliminar.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';
import 'package:smart_spend_app/domain/models/compra_model.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(compraRepositoryProvider);
  final db = ref.read(databaseProvider);
  return HomeNotifier(repository, db);
});

class HomeNotifier extends StateNotifier<HomeState> {
  final CompraRepository _repository;
  final AppDatabase _db;
  GlobalKey? dialogAgregarCompraKey;
  final GoRouter router = appRouter;

  HomeNotifier(this._repository, this._db) : super(HomeState());

  Future<void> updateCompra(CompraModel compra) async {
    await _repository.updateCompra(compra);

    await loadCompras();
  }

  Future<void> saveCompra(
      CompraModel compra, List<CompraDetalleModel> detalles) async {
    await _repository.createCompra(compra);

    await loadCompras();
  }

  Future<void> loadCompras() async {
    try {
      final compras = await _repository.getComprasWithDetails();
      state = state.copyWith(compras: compras);
    } catch (e) {
      print(e.toString());
    }
  }

  void selectCompra(CompraModel compra) {
    state = state.copyWith(
        selectedCompraId: compra.id!,
        isCompraSelected: true,
        selectedCompra: compra);
  }

  // Método para actualizar la compra seleccionada sin recargar todo
  void updateSelectedCompra(CompraModel updatedCompra) {
    // Actualizar en la lista de compras
    final updatedCompras = state.compras.map((compra) {
      if (compra.id == updatedCompra.id) {
        return updatedCompra;
      }
      return compra;
    }).toList();

    state = state.copyWith(
      compras: updatedCompras,
      selectedCompra: updatedCompra,
    );
  }

  Future<void> deleteCompra(int compraId) async {
    await _repository.deleteCompra(compraId);

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
    for (var compraId in state.selectedCompras) {
      await deleteCompra(compraId);
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
      {required BuildContext context, CompraModel? compra}) async {
    final TextEditingController titleController =
        TextEditingController(text: compra?.titulo ?? '');
    final TextEditingController presupuestoController =
        TextEditingController(text: compra?.presupuesto?.toString() ?? '');

    final FocusNode focusNode = FocusNode();
    final FocusNode presupuestoFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AddEditComprasDialog(
          key: dialogAgregarCompraKey,
          title: compra != null ? 'Editar compra' : 'Nueva compra',
          titleController: titleController,
          presupuestoController: presupuestoController,
          focusNode: focusNode,
          presupuestoFocusNode: presupuestoFocusNode,
          onPressed: () {
            _handleSaveCompra(
              context,
              titleController.text.trim(),
              presupuestoController.text.trim(),
              this,
              compra: compra,
            );
          },
        );
      },
    );
  }

  void _handleSaveCompra(
    BuildContext context,
    String title,
    String presupuestoText,
    HomeNotifier homeNotifier, {
    CompraModel? compra,
  }) {
    if (title.isNotEmpty) {
      final double? presupuesto = double.tryParse(presupuestoText);

      if (compra != null) {
        final updatedCompra = compra.copyWith(
          titulo: title,
          presupuesto: presupuesto,
        );
        homeNotifier.saveCompra(updatedCompra, []);
      } else {
        final nuevaCompra = CompraModel(
          titulo: title,
          fecha: DateTime.now(),
          presupuesto: presupuesto,
        );
        homeNotifier.saveCompra(nuevaCompra, []);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> showDeleteConfirmationDialog(
      {required BuildContext context, int? compraId}) async {
    dialogAgregarCompraKey = GlobalKey();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
            key: dialogAgregarCompraKey,
            onPressed: () {
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
    if (!state.isComprasSelected) return ' Listas';
    if (state.selectedCompras.isEmpty) return ' Seleccione elementos';
    if (state.selectedCompras.length > 1) {
      return ' ${state.selectedCompras.length} elementos seleccionados';
    } else {
      return ' 1 elemento seleccionado';
    }
  }

  Future<void> goDetalleCompra({required CompraModel compra}) async {
    selectCompra(compra);
    await router.push('/compra-detalle');
    await loadCompras();
  }

  Future<void> archiveCompra(int compraId) async {
    await _repository.archiveCompra(compraId);

    await loadCompras();
  }

  Future<void> archiveSelectedCompras() async {
    for (var compraId in state.selectedCompras) {
      await archiveCompra(compraId);
    }
    toggleComprasSelection();
    await loadCompras();
  }

  Future<void> showArchiveConfirmationDialog({
    required BuildContext context,
  }) async {
    dialogAgregarCompraKey = GlobalKey();

    return showDialog<void>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        onPressed: () async {
          await archiveSelectedCompras();
          Navigator.of(context).pop();
        },
        title: '¿Archivar compras?',
        message: 'Estas compras se moverán a la sección de archivadas.',
        confirmText: 'Archivar',
      ),
    );
  }

  Future<void> updateOrdenCompras(List<CompraModel> nuevasCompras) async {
    await _repository.updateComprasOrder(nuevasCompras);

    await loadCompras();
  }

  void toggleReordering() {
    if (state.compras.isEmpty) return;

    state = state.copyWith(isReordering: !state.isReordering);
  }

  shareJson(BuildContext context) async {
    try {
      await Utils.exportAndShareJson(_db);
    } catch (e) {
      print("Error al compartir JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al compartir el archivo')),
      );
    }
  }

  shareSelectedJson(BuildContext context) async {
    try {
      if (state.selectedCompras.isEmpty) return;
      await Utils.exportAndShareJson(_db, ids: state.selectedCompras);
      toggleComprasSelection(); // Exit selection mode after sharing
    } catch (e) {
      print("Error al compartir JSON seleccionado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al compartir el archivo')),
      );
    }
  }
}

class HomeState {
  final List<CompraModel> compras;
  final int? selectedCompraId;
  final bool isComprasSelected;
  final List<int> selectedCompras;
  CompraModel? selectedCompra;
  final bool isReordering;

  HomeState({
    this.compras = const [],
    this.selectedCompraId,
    this.isComprasSelected = false,
    this.selectedCompras = const [],
    this.selectedCompra,
    this.isReordering = false,
  });

  HomeState copyWith({
    List<CompraModel>? compras,
    int? selectedCompraId,
    bool? isCompraSelected,
    bool? isComprasSelected,
    List<int>? selectedCompras,
    CompraModel? selectedCompra,
    bool? isReordering,
  }) {
    return HomeState(
      compras: compras ?? this.compras,
      selectedCompraId: selectedCompraId ?? this.selectedCompraId,
      isComprasSelected: isComprasSelected ?? this.isComprasSelected,
      selectedCompras: selectedCompras ?? this.selectedCompras,
      selectedCompra: selectedCompra ?? this.selectedCompra,
      isReordering: isReordering ?? this.isReordering,
    );
  }
}

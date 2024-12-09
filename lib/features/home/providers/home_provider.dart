import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/main.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_agregar_editar_compra.dart';
import 'package:smart_spend_app/features/home/widgets/dialog_confirmar_eliminar.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';
import 'package:smart_spend_app/models/compra_model.dart';

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(() => HomeNotifier());

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState();
  }

  final GoRouter router = appRouter;

  AppDatabase get _db => ref.read(databaseProvider);
  GlobalKey? dialogAgregarCompraKey;

  Future<void> updateCompra(CompraModel compra) async {
    await _db.updateCompra(ComprasCompanion(
        id: Value(compra.id!),
        fecha: Value(compra.fecha.toIso8601String()),
        titulo: Value(compra.titulo)));

    await loadCompras();
  }

  Future<void> saveCompra(
      CompraModel compra, List<CompraDetalleModel> detalles) async {
    final compraId = await _db.into(_db.compras).insert(
          ComprasCompanion(
            titulo: Value(compra.titulo),
            fecha: Value(compra.fecha.toIso8601String()),
          ),
        );

    //final compraId = await _dbHelper.insertCompra(compra);

    // for (var detalle in detalles) {
    //   await _dbHelper.insertCompraDetalle(detalle.copyWith(compraId: compraId));
    // }

    for (var detalle in detalles) {
      await _db.into(_db.compraDetalles).insert(
            CompraDetallesCompanion(
              nombre: Value(detalle.nombre),
              precio: Value(detalle.precio),
              compra: Value(compraId),
              fecha: Value(detalle.fecha.toIso8601String()),
            ),
          );
    }

    await loadCompras();
  }

  Future<void> loadCompras() async {
    final compras = await _db.select(_db.compras).get();

    // Obtener detalles asociados
    final comprasConDetalles = await Future.wait(compras.map((compra) async {
      final detalles = await (_db.select(_db.compraDetalles)
            ..where((tbl) => tbl.compra.equals(compra.id)))
          .get();

      return CompraModel(
        id: compra.id,
        titulo: compra.titulo,
        fecha: DateTime.parse(compra.fecha),
        detalles: detalles.map((detalle) {
          return CompraDetalleModel(
            id: detalle.id,
            nombre: detalle.nombre,
            precio: detalle.precio,
            compraId: detalle.compra,
            fecha: DateTime.parse(detalle.fecha),
          );
        }).toList(),
      );
    }).toList());

    state = state.copyWith(compras: comprasConDetalles);
  }

  void selectCompra(CompraModel compra) {
    state = state.copyWith(
        selectedCompraId: compra.id!,
        isCompraSelected: true,
        selectedCompra: compra);
  }

  Future<void> deleteCompra(int compraId) async {
    await (_db.delete(_db.compras)..where((tbl) => tbl.id.equals(compraId)))
        .go();
    await (_db.delete(_db.compraDetalles)
          ..where((tbl) => tbl.compra.equals(compraId)))
        .go();

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
    final FocusNode focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    final homeNotifier = ref.read(homeProvider.notifier);
    dialogAgregarCompraKey = GlobalKey();

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AddEditComprasDialog(
            key: dialogAgregarCompraKey,
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
      {CompraModel? compra}) {
    if (title.isNotEmpty) {
      if (compra != null) {
        final updatedCompra = compra.copyWith(titulo: title);
        homeNotifier
            .saveCompra(updatedCompra, []); // Guarda la compra actualizada
      } else {
        final compra = CompraModel(
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
    if (!state.isComprasSelected) return ' Mis listas';
    if (state.selectedCompras.isEmpty) return ' Seleccione elementos';
    if (state.selectedCompras.length > 1) {
      return ' ${state.selectedCompras.length} elementos seleccionados';
    } else {
      return ' 1 elemento seleccionado';
    }
  }

  Future<void> goDetalleCompra({required CompraModel compra}) async {
    selectCompra(compra);
    ref.read(compraDetalleProvider.notifier).initLoading();
    router.push('/compra-detalle');
  }
}

class HomeState {
  final List<CompraModel> compras;
  final int? selectedCompraId;
  final bool isComprasSelected;
  final List<int> selectedCompras;
  CompraModel? selectedCompra;

  HomeState(
      {this.compras = const [],
      this.selectedCompraId,
      this.isComprasSelected = false,
      this.selectedCompras = const [],
      this.selectedCompra});

  HomeState copyWith(
      {List<CompraModel>? compras,
      int? selectedCompraId,
      bool? isCompraSelected,
      bool? isComprasSelected,
      List<int>? selectedCompras,
      CompraModel? selectedCompra}) {
    return HomeState(
      compras: compras ?? this.compras,
      selectedCompraId: selectedCompraId ?? this.selectedCompraId,
      isComprasSelected: isComprasSelected ?? this.isComprasSelected,
      selectedCompras: selectedCompras ?? this.selectedCompras,
      selectedCompra: selectedCompra ?? this.selectedCompra,
    );
  }
}

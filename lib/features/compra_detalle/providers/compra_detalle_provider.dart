import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/dialog_add_detalle.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/main.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';
import 'package:smart_spend_app/domain/models/compra_model.dart';

final compraDetalleProvider =
    StateNotifierProvider<CompraDetalleNotifier, CompraDetalleState>(
  (ref) => CompraDetalleNotifier(ref),
);

class CompraDetalleNotifier extends StateNotifier<CompraDetalleState> {
  CompraDetalleNotifier(this.ref) : super(CompraDetalleState());

  final StateNotifierProviderRef ref;

  AppDatabase get _db => ref.read(databaseProvider);

  GlobalKey? dialogAgregarDetalleKey;

  Future<void> initDatos({required bool withLoad}) async {
    final compra = ref.read(homeProvider).selectedCompra;

    state = state.copyWith(
      isEditing: false,
      isDetallesSelected: false,
      detalles: compra?.detalles ?? [],
      isLoading: false,
      compra: compra,
      compraId: compra?.id,
    );

    if (withLoad) {}
  }

  void initLoading() {
    state = state.copyWith(isLoading: true);
  }

  Future<List<CompraDetalleModel>> loadCompraDetalles(int compraId) async {
    final detalles = await (_db.select(_db.compraDetalles)
          ..where((tbl) => tbl.compra.equals(compraId)))
        .get();

    final mappedDetalles = detalles.map((detalle) {
      return CompraDetalleModel(
        id: detalle.id,
        nombre: detalle.nombre,
        precio: detalle.precio,
        compraId: detalle.compra,
        fecha: DateTime.parse(detalle.fecha),
      );
    }).toList();

    state = state.copyWith(
      detalles: mappedDetalles,
      compraId: compraId,
      isLoading: false,
    );
    return mappedDetalles;
  }

  Future<void> addDetalle(CompraDetalleModel detalle) async {
    // Insertar el nuevo detalle
    final newId = await _db.into(_db.compraDetalles).insert(
          CompraDetallesCompanion(
            nombre: Value(detalle.nombre),
            precio: Value(detalle.precio),
            compra: Value(detalle.compraId),
            fecha: Value(detalle.fecha.toIso8601String()),
          ),
        );

    // Crear modelo completo con ID generado
    final newDetalle = detalle.copyWith(id: newId);

    // Actualizar el estado local
    final updatedDetalles = [...state.detalles, newDetalle];

    state = state.copyWith(detalles: updatedDetalles);

    // Actualizar también la compra seleccionada en HomeNotifier
    final homeNotifier = ref.read(homeProvider.notifier);
    final selectedCompra = ref.read(homeProvider).selectedCompra;

    if (selectedCompra != null) {
      final updatedCompra = selectedCompra.copyWith(detalles: updatedDetalles);
      homeNotifier.state =
          homeNotifier.state.copyWith(selectedCompra: updatedCompra);
    }
  }

  Future<void> updateDetalle(
      int index, CompraDetalleModel updatedDetalle) async {
    await _db.into(_db.compraDetalles).insert(
          CompraDetallesCompanion(
            id: Value(updatedDetalle.id!),
            nombre: Value(updatedDetalle.nombre),
            precio: Value(updatedDetalle.precio),
            compra: Value(updatedDetalle.compraId),
            fecha: Value(updatedDetalle.fecha.toIso8601String()),
          ),
          mode: InsertMode.replace,
        );

    await loadCompraDetalles(updatedDetalle.compraId);
    await ref.read(homeProvider.notifier).loadCompras();
  }

  Future<void> deleteSelectedDetalles() async {
    for (var index in state.selectedDetalles) {
      final detalle = state.detalles[index];
      await (_db.delete(_db.compraDetalles)
            ..where((tbl) => tbl.id.equals(detalle.id!)))
          .go();
    }

    toggleDetallesSelection();
    await ref.read(homeProvider.notifier).loadCompras();
    await loadCompraDetalles(state.compraId);
  }

  Future<void> deleteCurrentCompraDetalle(int compraDetalleId) async {
    await (_db.delete(_db.compraDetalles)
          ..where((tbl) => tbl.id.equals(compraDetalleId)))
        .go();

    await loadCompraDetalles(state.compraId);
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
              ref.read(compraDetalleProvider.notifier).addDetalle(
                    CompraDetalleModel(
                      nombre: nombre,
                      precio: precio,
                      compraId: state.compraId,
                      fecha: DateTime.now(),
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
      ref.read(homeProvider.notifier).updateCompra(updatedCompra);
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

  Future<void> savePresupuesto(double? nuevoPresupuesto) async {
    final compraActual = state.compra;
    if (compraActual == null || compraActual.id == null) return;

    final db = ref.read(databaseProvider);

    await (db.update(db.compras)
          ..where((tbl) => tbl.id.equals(compraActual.id!)))
        .write(
      ComprasCompanion(
        presupuesto: Value(nuevoPresupuesto),
      ),
    );

    state = state.copyWith(
      compra: compraActual.copyWith(presupuesto: nuevoPresupuesto),
    );
  }
}

class CompraDetalleState {
  final List<CompraDetalleModel> detalles;
  final CompraModel? compra;
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
        isDetallesSelected: isDetallesSelected ?? this.isDetallesSelected,
        selectedDetalles: selectedDetalles ?? this.selectedDetalles,
        isEditing: isEditing ?? this.isEditing,
        isLoading: isLoading ?? this.isLoading,
        compra: compra ?? this.compra);
  }
}

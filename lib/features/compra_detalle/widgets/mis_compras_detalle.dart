import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/mis_compras_detalle_skeleton.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/models/compra_detalle_model.dart';

class MisComprasDetalle extends ConsumerWidget {
  const MisComprasDetalle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compraDetalleState = ref.watch(compraDetalleProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: compraDetalleState.isLoading
          ? ListView.separated(
              itemCount: 5, // Muestra 5 skeletons
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.gray100,
                height: 0,
                thickness: 1,
              ),
              itemBuilder: (context, index) =>
                  const ComprasDetalleRowSkeleton(),
            )
          : ListView.separated(
              itemCount: compraDetalleState.detalles.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.gray100,
                height: 0, // Reduce el espacio entre los ítems
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final compraDetalle = compraDetalleState.detalles[index];
                return _ComprasDetalleRow(
                  compraDetalle: compraDetalle,
                  index: index,
                  isSelected:
                      compraDetalleState.selectedDetalles.contains(index),
                );
              },
            ),
    );
  }
}

class _ComprasDetalleRow extends ConsumerStatefulWidget {
  final CompraDetalle compraDetalle;
  final int index;
  final bool isSelected;

  const _ComprasDetalleRow({
    required this.compraDetalle,
    required this.index,
    required this.isSelected,
  });

  @override
  _ComprasDetalleRowState createState() => _ComprasDetalleRowState();
}

class _ComprasDetalleRowState extends ConsumerState<_ComprasDetalleRow> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late FocusNode _nombreFocusNode;
  late FocusNode _precioFocusNode;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.compraDetalle.nombre);
    _precioController = TextEditingController(
        text: widget.compraDetalle.precio.toStringAsFixed(2));
    _nombreFocusNode = FocusNode();
    _precioFocusNode = FocusNode();

    _nombreFocusNode.addListener(_onFocusChange);
    _precioFocusNode.addListener(_onPrecioFocus);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _nombreFocusNode.dispose();
    _precioFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_nombreFocusNode.hasFocus) {
      _saveDetalle();
    }
  }

  void _onPrecioFocus() {
    if (_precioFocusNode.hasFocus) {
      if (_precioController.text == '0.00' || _precioController.text == '0') {
        _precioController.clear();
      }
    } else {
      _saveDetalle();
    }
  }

  void _toggleEditing() {
    ref.read(compraDetalleProvider.notifier).toggleEditing();
    if (ref.watch(compraDetalleProvider).isEditing) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _nombreFocusNode.requestFocus();
      });
    } else {
      _saveDetalle();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _saveDetalle() async {
    final newNombre = _nombreController.text.trim();
    final newPrecioText = _precioController.text.trim();
    final newPrecio = double.tryParse(newPrecioText) ?? 0.00;

    final formattedPrecio = double.parse(newPrecio.toStringAsFixed(2));
    _precioController.text = formattedPrecio.toStringAsFixed(2);

    if (newNombre.isNotEmpty &&
        (newNombre != widget.compraDetalle.nombre ||
            formattedPrecio != widget.compraDetalle.precio)) {
      final updatedDetalle = CompraDetalle(
        id: widget.compraDetalle.id,
        nombre: newNombre,
        precio: formattedPrecio,
        compraId: widget.compraDetalle.compraId,
        fecha: widget.compraDetalle.fecha, // Preservar la fecha original
      );

      await ref
          .read(compraDetalleProvider.notifier)
          .updateDetalle(widget.index, updatedDetalle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isSelected ? AppColors.gray100 : AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nombreController,
                  focusNode: _nombreFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.gray500,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  //onSubmitted: (_) async => await _saveDetalle(),
                ),
              ),
              const SizedBox(width: 8.0), // Space between fields
              const Text(
                'S/',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _precioController,
                  focusNode: _precioFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Precio',
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.gray500,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: AppColors.gray700,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  //onSubmitted: (_) async => await _saveDetalle(),
                ),
              ),
              const SizedBox(width: 8.0), // Space before icon
              const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.close,
                  color: AppColors.primary500, // Set the color of the icon
                  size: 20.0, // Reduce the size of the icon
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0), // Space between fields and date
          Text(
            Utils.FormattedDate(compraFecha: widget.compraDetalle.fecha),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

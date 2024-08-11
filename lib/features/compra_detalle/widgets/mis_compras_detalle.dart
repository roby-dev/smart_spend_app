import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
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
      child: ListView.separated(
        itemCount: compraDetalleState.detalles.length,
        separatorBuilder: (context, index) => const Divider(
            color: AppColors.gray100,
            height: 0 // Reduce el espacio entre los items
            ),
        itemBuilder: (context, index) {
          final compraDetalle = compraDetalleState.detalles[index];
          return _ComprasDetalleCard(
            compra: compraDetalle,
            index: index,
            isSelected: compraDetalleState.selectedDetalles.contains(index),
          );
        },
      ),
    );
  }
}

class _ComprasDetalleCard extends ConsumerStatefulWidget {
  final CompraDetalle compra;
  final int index;
  final bool isSelected;

  const _ComprasDetalleCard({
    required this.compra,
    required this.index,
    required this.isSelected,
  });

  @override
  _ComprasDetalleCardState createState() => _ComprasDetalleCardState();
}

class _ComprasDetalleCardState extends ConsumerState<_ComprasDetalleCard> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late FocusNode _nombreFocusNode;
  late FocusNode _precioFocusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.compra.nombre);
    _precioController =
        TextEditingController(text: widget.compra.precio.toStringAsFixed(2));
    _nombreFocusNode = FocusNode();
    _precioFocusNode = FocusNode();

    _nombreFocusNode.addListener(_onFocusChange);
    _precioFocusNode.addListener(_onFocusChange);
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
    if (!_precioFocusNode.hasFocus) {
      _saveDetalle();
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // Request focus for the name field when entering edit mode
        Future.delayed(Duration(milliseconds: 100), () {
          _nombreFocusNode.requestFocus();
        });
      } else {
        _saveDetalle();
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _saveDetalle() {
    final newNombre = _nombreController.text.trim();
    final newPrecioText = _precioController.text.trim();
    final newPrecio = double.tryParse(newPrecioText) ?? 0.00;

    _precioController.text = newPrecio.toStringAsFixed(2);

    if (newNombre.isNotEmpty &&
        (newNombre != widget.compra.nombre ||
            newPrecio != widget.compra.precio)) {
      final updatedDetalle = CompraDetalle(
        id: widget.compra.id,
        nombre: newNombre,
        precio: newPrecio,
        compraId: widget.compra.compraId,
      );

      ref
          .read(compraDetalleProvider.notifier)
          .updateDetalle(widget.index, updatedDetalle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiSelectMode = ref.watch(
        compraDetalleProvider.select((state) => state.isDetallesSelected));

    return Card(
      elevation: 0,
      color: widget.isSelected ? AppColors.gray100 : AppColors.white,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onLongPress: () {
          ref.read(compraDetalleProvider.notifier).toggleDetallesSelection();
          ref
              .read(compraDetalleProvider.notifier)
              .toggleDetalleSelection(widget.index);
        },
        onTap: !isMultiSelectMode
            ? null
            : () {
                if (isMultiSelectMode) {
                  ref
                      .read(compraDetalleProvider.notifier)
                      .toggleDetalleSelection(widget.index);
                }
              },
        contentPadding:
            const EdgeInsets.only(left: 20.0, right: 10.0, top: 0, bottom: 0),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _nombreController,
                focusNode: _nombreFocusNode,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  hintText: 'Nombre',
                  border: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.gray300,
                      width: 1.0,
                    ),
                  ),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                onSubmitted: (_) => _saveDetalle(),
              ),
            ),
            const SizedBox(width: 8.0), // Spacer between fields and button
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _toggleEditing,
              color: AppColors.gray700,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            const Text(
              'S/',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: AppColors.gray500,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _precioController,
                focusNode: _precioFocusNode,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  hintText: 'Precio',
                  border: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.gray300,
                      width: 1.0,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray500,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _saveDetalle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

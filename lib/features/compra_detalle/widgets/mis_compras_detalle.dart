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
      child: ListView.builder(
        itemCount: compraDetalleState.detalles.length,
        itemBuilder: (context, index) {
          final compraDetalle = compraDetalleState.detalles[index];
          return _EditableDetalleRow(compra: compraDetalle, index: index);
        },
      ),
    );
  }
}

class _EditableDetalleRow extends ConsumerStatefulWidget {
  final CompraDetalle compra;
  final int index;

  const _EditableDetalleRow({required this.compra, required this.index});

  @override
  _EditableDetalleRowState createState() => _EditableDetalleRowState();
}

class _EditableDetalleRowState extends ConsumerState<_EditableDetalleRow> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late FocusNode _nombreFocusNode;
  late FocusNode _precioFocusNode;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.compra.nombre);
    _precioController = TextEditingController(
        text: widget.compra.precio
            .toStringAsFixed(2)); // Formatear precio inicial
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

  void _saveDetalle() {
    final newNombre = _nombreController.text.trim();
    final newPrecioText = _precioController.text.trim();
    final newPrecio = double.tryParse(newPrecioText) ?? 0.00;

    // Formatear el precio después de perder el foco o guardar
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _nombreController,
              focusNode: _nombreFocusNode,
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              onSubmitted: (_) => _saveDetalle(),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Text(
                  'S/',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray500),
                ),
                Expanded(
                  child: TextField(
                    controller: _precioController,
                    focusNode: _precioFocusNode,
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
                        color: AppColors.gray500),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onSubmitted: (_) => _saveDetalle(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

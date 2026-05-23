import 'package:flutter/material.dart';

class AddDetalleDialog extends StatelessWidget {
  final int compraId;
  final void Function() onPressed;

  final TextEditingController nombreController;
  final TextEditingController precioController;
  final FocusNode nombreFocusNode;
  final FocusNode preciFocusNode;

  const AddDetalleDialog(
      {super.key,
      required this.compraId,
      required this.onPressed,
      required this.nombreController,
      required this.precioController,
      required this.nombreFocusNode,
      required this.preciFocusNode});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nombreFocusNode.requestFocus();
    });

    return AlertDialog(
      title: const Text(
        'Añadir Detalle',
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: nombreController,
              focusNode: nombreFocusNode,
              decoration: const InputDecoration(labelText: 'Nombre'),
              style: const TextStyle(fontWeight: FontWeight.w300),
              onSubmitted: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  preciFocusNode.requestFocus();
                  precioController.text = "";
                });
              }),
          TextField(
            controller: precioController,
            focusNode: preciFocusNode,
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w300),
            onSubmitted: (value) => onPressed(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AddDetalleDialog extends StatelessWidget {
  final int compraId;
  final void Function() onPressed;

  final TextEditingController nombreController;
  final TextEditingController precioController;

  const AddDetalleDialog(
      {super.key,
      required this.compraId,
      required this.onPressed,
      required this.nombreController,
      required this.precioController});

  @override
  Widget build(BuildContext context) {
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
            decoration: const InputDecoration(labelText: 'Nombre'),
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
          TextField(
            controller: precioController,
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w300),
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

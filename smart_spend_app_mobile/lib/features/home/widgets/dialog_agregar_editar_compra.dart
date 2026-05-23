import 'package:flutter/material.dart';

class AddEditComprasDialog extends StatelessWidget {
  final void Function() onPressed;
  final TextEditingController titleController;
  final TextEditingController presupuestoController;
  final String title;
  final FocusNode focusNode;
  final FocusNode presupuestoFocusNode;

  const AddEditComprasDialog({
    super.key,
    required this.onPressed,
    required this.titleController,
    required this.presupuestoController,
    required this.title,
    required this.focusNode,
    required this.presupuestoFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: titleController,
            focusNode: focusNode,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Título de la compra',
              hintStyle: TextStyle(fontWeight: FontWeight.w300),
            ),
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(presupuestoFocusNode);
            },
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: presupuestoController,
            focusNode: presupuestoFocusNode,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Presupuesto (opcional)',
              hintStyle: TextStyle(fontWeight: FontWeight.w300),
            ),
            onSubmitted: (_) => onPressed(),
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

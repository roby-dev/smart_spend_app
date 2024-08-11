import 'package:flutter/material.dart';

class AddEditComprasDialog extends StatelessWidget {
  final void Function() onPressed;
  final TextEditingController titleController;
  final String title;
  final FocusNode focusNode;

  const AddEditComprasDialog(
      {super.key,
      required this.onPressed,
      required this.titleController,
      required this.title,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
      content: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: titleController,
        focusNode: focusNode,
        decoration: const InputDecoration(
            hintText: 'Título de la compra',
            hintStyle: TextStyle(fontWeight: FontWeight.w300)),
        onSubmitted: (String value) {
          onPressed();
        },
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
      actions: <Widget>[
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

import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final void Function() onPressed;

  const DeleteConfirmationDialog({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atención'),
      content: const Text('¿Estás seguro de que desea realizar esta acción?'),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}

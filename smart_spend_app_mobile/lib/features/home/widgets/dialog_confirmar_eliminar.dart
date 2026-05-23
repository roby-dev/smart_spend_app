import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final String message;
  final String confirmText;

  const DeleteConfirmationDialog({
    super.key,
    required this.onPressed,
    this.title = 'Atención',
    this.message = '¿Estás seguro de que deseas realizar esta acción?',
    this.confirmText = 'Confirmar',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

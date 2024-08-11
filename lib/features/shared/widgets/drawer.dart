import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.gray100, // Fondo del Drawer
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.gray300, // Fondo del título
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: AppColors.gray900, // Color del texto
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note_add, color: AppColors.black),
            title: const Text('Guardar Notas',
                style: TextStyle(color: AppColors.black)),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              _saveNoteDialog(context); // Abre un diálogo para guardar notas
            },
          ),
        ],
      ),
    );
  }

  void _saveNoteDialog(BuildContext context) {
    String note = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar Nota'),
          content: TextField(
            onChanged: (value) {
              note = value;
            },
            decoration: const InputDecoration(hintText: "Escribe tu nota aquí"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                // Aquí puedes agregar la lógica para guardar la nota utilizando Riverpod
                print('Nota guardada: $note');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

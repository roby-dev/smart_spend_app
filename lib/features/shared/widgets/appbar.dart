import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size(double.infinity, 56);

  final bool showDeleteAction;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  final VoidCallback importFromJson;
  final VoidCallback exportToJson;
  final VoidCallback signOut;

  final User? user;

  const MyAppBar({
    super.key,
    this.showDeleteAction = false,
    this.onDelete,
    this.onCancel,
    required this.importFromJson,
    required this.exportToJson,
    this.user,
    required this.signOut,
  });

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = user?.photoURL;

    return AppBar(
      leading: showDeleteAction
          ? IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: onCancel,
              color: AppColors.gray700,
              iconSize: 30,
            )
          : null,
      actions: [
        showDeleteAction
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                color: AppColors.gray700,
                iconSize: 30,
              )
            : PopupMenuButton<int>(
                onSelected: (item) {
                  if (item == 0) {
                    exportToJson();
                  } else if (item == 1) {
                    importFromJson();
                  } else if (item == 2) {
                    signOut();
                  }
                },
                icon: photoUrl == null
                    ? const Icon(Icons.settings)
                    : CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                        radius: 15,
                      ),
                color: AppColors.gray100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Exportar a JSON'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Importar desde JSON'),
                  ),
                  if (user != null)
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text('Cerrar sesión'),
                    ),
                ],
              ),
      ],
      backgroundColor: AppColors.gray100,
      iconTheme: const IconThemeData(color: AppColors.black),
    );
  }
}

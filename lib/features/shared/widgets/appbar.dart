import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size(double.infinity, 30);

  final bool showDeleteAction;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const MyAppBar({
    super.key,
    this.showDeleteAction = false,
    this.onDelete,
    this.onCancel,
  });

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        print('Cambiar perfil seleccionado');
        break;
      case 1:
        print('Configuración seleccionada');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onSelected: (item) => onSelected(context, item),
                icon: const Icon(Icons.settings),
                color: AppColors.gray100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Cambiar perfil'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Configuración'),
                  ),
                ],
              ),
      ],
      backgroundColor: AppColors.gray100,
      iconTheme: const IconThemeData(color: AppColors.black),
    );
  }
}

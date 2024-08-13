import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size(double.infinity, 56);

  final bool showDeleteAction;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const MyAppBar({
    super.key,
    this.showDeleteAction = false,
    this.onDelete,
    this.onCancel,
  });

  Future<void> exportToJson(BuildContext context) async {}

  Future<void> importFromJson(BuildContext context) async {}

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
                onSelected: (item) {
                  if (item == 0) {
                    exportToJson(context);
                  } else if (item == 1) {
                    importFromJson(context);
                  }
                },
                icon: const Icon(Icons.more_vert),
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
                ],
              ),
      ],
      backgroundColor: AppColors.gray100,
      iconTheme: const IconThemeData(color: AppColors.black),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function()? onBack;
  final bool isDetallesSelected;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  @override
  final Size preferredSize = const Size(double.infinity, 30);

  const MyAppBar2({
    super.key,
    this.onBack,
    required this.isDetallesSelected,
    this.onDelete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: isDetallesSelected
          ? IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: onCancel,
              color: AppColors.gray700,
              iconSize: 30,
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  context.pop();
                }
              },
              color: AppColors.gray700,
              iconSize: 30,
            ),
      actions: [
        if (isDetallesSelected)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            color: AppColors.gray700,
            iconSize: 30,
          ),
      ],
      backgroundColor: AppColors.gray100,
      iconTheme: const IconThemeData(color: AppColors.black),
    );
  }
}

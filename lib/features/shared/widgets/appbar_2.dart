import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class MyAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function()? onBack;

  @override
  final Size preferredSize = const Size(double.infinity, 30);

  const MyAppBar2({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          // Si algún campo de texto (hijo) tiene el foco, escondemos el teclado
          if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          } else {
            // Si el teclado no está abierto, retrocedemos de pantalla normalmente
            if (onBack != null) {
              onBack!();
            } else {
              context.pop();
            }
          }
        },
        color: AppColors.gray700,
        iconSize: 30,
      ),
      backgroundColor: AppColors.gray100,
      iconTheme: const IconThemeData(color: AppColors.black),
    );
  }
}

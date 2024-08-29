import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/features/shared/widgets/checkbox_rounded.dart';
import 'package:smart_spend_app/models/compra_model.dart';

// class MisCompras extends ConsumerWidget {
//   final Compra compra;

//   const MisCompras({super.key, required this.compra});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final homeState = ref.watch(homeProvider);

//     return ListView.builder(
//       itemCount: homeState.compras.length,
//       itemBuilder: (context, index) {
//         final compra = homeState.compras[index];
//         return _ComprasCard(compra: compra);
//       },
//     );
//   }
// }
class ComprasCard extends ConsumerWidget {
  const ComprasCard({
    super.key,
    required this.compra,
  });

  final Compra compra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final isSelected = homeState.selectedCompras.contains(compra.id);
    final bool isMultiSelectMode = homeState.isComprasSelected;

    // Calcula el total de los precios de los detalles
    final double total = compra.detalles.fold(
      0.0,
      (sum, detalle) => sum + detalle.precio,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Stack(children: [
        ListTile(
          onTap: () async {
            if (isMultiSelectMode) {
              ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
            } else {
              await ref
                  .read(homeProvider.notifier)
                  .goDetalleCompra(compra: compra);
            }
          },
          onLongPress: () {
            ref.read(homeProvider.notifier).toggleComprasSelection();
            ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
          },
          title: Text(
            compra.titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          contentPadding: EdgeInsets.only(
              top: 0, bottom: 16, left: isMultiSelectMode ? 40 : 16, right: 16),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          tileColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          selected: isSelected,
          selectedTileColor: Colors.grey.shade200,
        ),
        Positioned(
          bottom: 8,
          right: 16,
          child: Text(
            Utils.FormattedDate(compraFecha: compra.fecha),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.gray500,
            ),
          ),
        ),
        if (isMultiSelectMode)
          Positioned(
            top: 4,
            left: 0,
            child: RoundedCheckbox(
              value: isSelected,
              onChanged: (bool? value) {
                ref
                    .read(homeProvider.notifier)
                    .toggleCompraSelection(compra.id!);
              },
            ),
          ),
      ]),
    );
  }
}
